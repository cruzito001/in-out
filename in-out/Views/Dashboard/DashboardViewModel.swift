//
//  DashboardViewModel.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI
import SwiftData

@MainActor
class DashboardViewModel: ObservableObject {
    // MARK: - UI State
    @Published var selected: Segment = .resumen
    @Published var selectedPeriod: Period = .mesActual
    @Published var selectedCategoryName: String = "Todas"
    @Published var showAllCategories: Bool = false
    @Published var selectedChartRange: ChartRange = .last3Months
    @Published var selectedChartCurrency: String = "MXN"
    
    // MARK: - Navigation State
    @Published var showAddSheet: Bool = false
    @Published var showAddCategorySheet: Bool = false
    @Published var showDeleteError: Bool = false
    @Published var deleteErrorMessage: String = ""
    @Published var expenseToEdit: Expense?
    @Published var showDeleteConfirm: Bool = false
    @Published var expensePendingDelete: Expense?

    // MARK: - Data Helpers
    
    func combinedCategories(customCategories: [Category]) -> [CategoryItem] {
        var base = PredefinedCategories.all
        let customs = customCategories.map { CategoryItem(id: $0.id.uuidString, name: $0.name, symbol: $0.symbol) }
        let all = base + customs
        var seen = Set<String>()
        return all.filter { item in
            let key = item.name.lowercased()
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }
    
    func symbolForCategory(_ name: String, customCategories: [Category]) -> String {
        if let item = PredefinedCategories.all.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return item.symbol
        }
        if let custom = customCategories.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return custom.symbol
        }
        return "tag.fill"
    }
    
    func filteredExpenses(allExpenses: [Expense]) -> [Expense] {
        let range = dateInterval(for: selectedPeriod)
        return allExpenses.filter { exp in
            range.contains(exp.date) &&
            (selectedCategoryName == "Todas" || exp.category.lowercased() == selectedCategoryName.lowercased())
        }
    }
    
    func dateInterval(for period: Period) -> DateInterval {
        let cal = Calendar.current
        let now = Date()
        switch period {
        case .mesActual:
            let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .mesAnterior:
            let currentStart = cal.date(from: cal.dateComponents([.year, .month], from: now))!
            let start = cal.date(byAdding: .month, value: -1, to: currentStart)!
            return DateInterval(start: start, end: currentStart)
        case .tresMeses:
            let currentStart = cal.date(from: cal.dateComponents([.year, .month], from: now))!
            let start = cal.date(byAdding: .month, value: -2, to: currentStart)!
            let end = cal.date(byAdding: .month, value: 1, to: currentStart)!
            return DateInterval(start: start, end: end)
        case .anio:
            let comps = cal.dateComponents([.year], from: now)
            let start = cal.date(from: comps)!
            let end = cal.date(byAdding: .year, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .personalizado:
            // Por ahora usamos mes actual
            let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        }
    }
    
    // MARK: - Calculation Helpers
    
    func totalsByCurrency(_ expenses: [Expense]) -> [String: Int] {
        var totals: [String: Int] = [:]
        for e in expenses { totals[e.currencyCode, default: 0] += e.amountInCents }
        return totals
    }
    
    func topCategory(_ expenses: [Expense]) -> (name: String, total: Int, currency: String)? {
        var sums: [String: (total: Int, currency: String, count: Int)] = [:]
        for e in expenses {
            sums[e.category, default: (0, e.currencyCode, 0)].total += e.amountInCents
            sums[e.category, default: (0, e.currencyCode, 0)].count += 1
        }
        let sorted = sums.sorted { $0.value.total > $1.value.total }
        guard let first = sorted.first else { return nil }
        return (name: first.key, total: first.value.total, currency: first.value.currency)
    }
    
    func categoriesBreakdown(_ expenses: [Expense]) -> [(name: String, total: Int, currency: String)] {
        var acc: [String : (total: Int, currency: String)] = [:]
        for e in expenses {
            let key = e.category
            let prev = acc[key] ?? (0, e.currencyCode)
            acc[key] = (prev.total + e.amountInCents, prev.currency)
        }
        return acc.map { (name: $0.key, total: $0.value.total, currency: $0.value.currency) }
            .sorted { $0.total > $1.total }
    }
    
    func chartBuckets(allExpenses: [Expense], range: ChartRange, currency: String) -> [(label: String, total: Int)] {
        let cal = Calendar.current
        let now = Date()
        let expenses = allExpenses.filter { $0.currencyCode.uppercased() == currency.uppercased() }
        let dfMonth = DateFormatter(); dfMonth.locale = Locale(identifier: "es_MX"); dfMonth.setLocalizedDateFormatFromTemplate("MMM")
        let dfYear = DateFormatter(); dfYear.locale = Locale(identifier: "es_MX"); dfYear.setLocalizedDateFormatFromTemplate("yyyy")

        func sum(in interval: DateInterval) -> Int {
            expenses.filter { interval.contains($0.date) }.map { $0.amountInCents }.reduce(0, +)
        }

        switch range {
        case .last3Months:
            guard let currentMonth = cal.dateInterval(of: .month, for: now) else { return [] }
            var buckets: [(String, Int)] = []
            for i in stride(from: 2, through: 0, by: -1) {
                guard let start = cal.date(byAdding: .month, value: -i, to: currentMonth.start),
                      let monthInterval = cal.dateInterval(of: .month, for: start) else { continue }
                let label = dfMonth.string(from: monthInterval.start).capitalized
                buckets.append((label, sum(in: monthInterval)))
            }
            return buckets
        case .lastMonthByWeek:
            guard let monthInterval = cal.dateInterval(of: .month, for: now),
                  let weeksRange = cal.range(of: .weekOfMonth, in: .month, for: now) else { return [] }
            var buckets: [(String, Int)] = []
            for week in weeksRange {
                let label = "Sem \(week)"
                let total = expenses.filter {
                    cal.isDate($0.date, equalTo: monthInterval.start, toGranularity: .month) &&
                    cal.isDate($0.date, equalTo: monthInterval.start, toGranularity: .year) &&
                    cal.component(.weekOfMonth, from: $0.date) == week
                }.map { $0.amountInCents }.reduce(0, +)
                buckets.append((label, total))
            }
            return buckets
        case .lastYear:
            guard let currentMonth = cal.dateInterval(of: .month, for: now) else { return [] }
            var buckets: [(String, Int)] = []
            for i in stride(from: 11, through: 0, by: -1) {
                guard let start = cal.date(byAdding: .month, value: -i, to: currentMonth.start),
                      let monthInterval = cal.dateInterval(of: .month, for: start) else { continue }
                let label = dfMonth.string(from: monthInterval.start).capitalized
                buckets.append((label, sum(in: monthInterval)))
            }
            return buckets
        case .last3Years:
            guard let currentYear = cal.dateInterval(of: .year, for: now) else { return [] }
            var buckets: [(String, Int)] = []
            for i in stride(from: 2, through: 0, by: -1) {
                guard let start = cal.date(byAdding: .year, value: -i, to: currentYear.start),
                      let yearInterval = cal.dateInterval(of: .year, for: start) else { continue }
                let label = dfYear.string(from: yearInterval.start)
                buckets.append((label, sum(in: yearInterval)))
            }
            return buckets
        }
    }

    // MARK: - Trend Helpers
    
    func trendData(expenses: [Expense]) -> (values: [Double], labels: [String]) {
        let cal = Calendar.current
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_MX")
        df.setLocalizedDateFormatFromTemplate("d MMM")
        
        // Agrupar por día
        let grouped = Dictionary(grouping: expenses) { exp in
            cal.startOfDay(for: exp.date)
        }
        
        // Si no hay datos, retornar vacío
        let sortedKeys = grouped.keys.sorted()
        guard !sortedKeys.isEmpty else { return ([], []) }
        
        // Rellenar huecos si es periodo corto (ej. Mes actual)
        // Para simplificar, solo mostraremos los días con gastos ordenados
        let values = sortedKeys.map { date -> Double in
            let total = grouped[date]?.reduce(0) { $0 + $1.amountInCents } ?? 0
            return Double(total) / 100.0
        }
        
        let labels = sortedKeys.map { df.string(from: $0) }
        
        return (values, labels)
    }
    
    func averageDailySpend(expenses: [Expense]) -> Double {
        guard !expenses.isEmpty else { return 0 }
        let cal = Calendar.current
        let dates = expenses.map { cal.startOfDay(for: $0.date) }
        guard let minDate = dates.min(), let maxDate = dates.max() else { return 0 }
        
        let days = max(1, cal.dateComponents([.day], from: minDate, to: maxDate).day ?? 1)
        let totalCents = expenses.reduce(0) { $0 + $1.amountInCents }
        
        return (Double(totalCents) / 100.0) / Double(days)
    }
    
    func projectedEndOfMonth(expenses: [Expense], period: Period) -> Double {
        guard period == .mesActual else { return 0 }
        let cal = Calendar.current
        let now = Date()
        
        let totalCents = expenses.reduce(0) { $0 + $1.amountInCents }
        let currentTotal = Double(totalCents) / 100.0
        
        guard let range = cal.range(of: .day, in: .month, for: now) else { return currentTotal }
        let totalDays = range.count
        let currentDay = cal.component(.day, from: now)
        
        guard currentDay > 0 else { return 0 }
        let average = currentTotal / Double(currentDay)
        
        return average * Double(totalDays)
    }
    
    // MARK: - Formatting
    
    func formatAmount(_ cents: Int, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let value = Double(cents) / 100.0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    func symbolForCurrency(_ code: String) -> String {
        switch code.uppercased() {
        case "MXN": return "pesosign.circle"
        case "USD": return "dollarsign.circle"
        case "EUR": return "eurosign.circle"
        default: return "banknote"
        }
    }
    
    func shortDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_MX")
        df.setLocalizedDateFormatFromTemplate("d MMM yyyy, HH:mm")
        return df.string(from: date)
    }
    
    func colorForIndex(_ idx: Int) -> Color {
        let palette: [Color] = [.blue, .green, .orange, .pink, .purple, .teal, .indigo, .cyan]
        return palette[idx % palette.count]
    }
    
    func formatPercent(_ value: Double) -> String {
        let pct = max(0.0, min(1.0, value))
        return String(format: "%.0f%%", pct * 100.0)
    }
    
    // MARK: - Actions
    
    func deleteExpense(_ expense: Expense, modelContext: ModelContext) {
        modelContext.delete(expense)
        do {
            try modelContext.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            deleteErrorMessage = "No se pudo eliminar el gasto"
            showDeleteError = true
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    func askDelete(_ expense: Expense) {
        expensePendingDelete = expense
        showDeleteConfirm = true
    }
    
    func startEditing(_ expense: Expense) {
        expenseToEdit = expense
    }
}
