//
//  SpendingDashboardView.swift
//  in-out
//
//  Created by Alan Cruz on 14/10/25.
//

import SwiftUI
import SwiftData

struct SpendingDashboardView: View {
    // MARK: - Selector (tipo Mail)
    enum Segment: String, CaseIterable, Identifiable {
        case resumen = "Resumen"
        case transacciones = "Transacciones"
        case distribucion = "Distribución"
        case tendencia = "Tendencia"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .resumen: return "person"
            case .transacciones: return "cart"
            case .distribucion: return "text.bubble"
            case .tendencia: return "speaker.wave.2"
            }
        }
    }
    
    // MARK: - Filtros secundarios
    enum Period: String, CaseIterable, Identifiable {
        case mesActual = "Mes actual"
        case mesAnterior = "Mes anterior"
        case tresMeses = "3 meses"
        case anio = "Año"
        case personalizado = "Personalizado"
        var id: String { rawValue }
    }
    
    @State private var selected: Segment = .resumen
    @State private var showAddSheet: Bool = false
    @State private var showAddCategorySheet: Bool = false
    @State private var selectedPeriod: Period = .mesActual
    @State private var selectedCategoryName: String = "Todas"
    @Query(sort: \Category.name) private var customCategories: [Category]
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteError: Bool = false
    @State private var deleteErrorMessage: String = ""
    @State private var expenseToEdit: Expense?
    @State private var showDeleteConfirm: Bool = false
    @State private var expensePendingDelete: Expense?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            transactionsList
                .safeAreaInset(edge: .top) {
                    header
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                }
        }
        .alert("Error", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteErrorMessage)
        }
        .fullScreenCover(isPresented: $showAddSheet) {
            AddExpenseView()
                .presentationBackground(.thinMaterial)
        }
        .fullScreenCover(isPresented: $showAddCategorySheet) {
            AddCategoryView()
                .presentationBackground(.thinMaterial)
        }
        .fullScreenCover(item: $expenseToEdit) { expense in
            EditExpenseView(expense: expense)
                .presentationBackground(.thinMaterial)
        }
        .confirmationDialog("¿Eliminar gasto?", isPresented: $showDeleteConfirm) {
            Button("Eliminar", role: .destructive) {
                if let e = expensePendingDelete {
                    deleteExpense(e)
                    expensePendingDelete = nil
                }
            }
            Button("Cancelar", role: .cancel) {
                expensePendingDelete = nil
            }
        } message: {
            if let e = expensePendingDelete {
                Text("¿Quieres eliminar “\(e.title ?? e.category)”?")
            } else {
                Text("Eliminar gasto")
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Control de gastos")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                Text("Actualizado justo ahora • \(allExpenses.count == 1 ? "1 gasto" : "\(allExpenses.count) gastos")")
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Menu {
                Button(action: { showAddSheet = true }) {
                    Label("Agregar gasto", systemImage: "plus.circle")
                }
                Button(action: { showAddCategorySheet = true }) {
                    Label("Agregar categoría", systemImage: "folder.badge.plus")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(10)
                    .background(.thinMaterial, in: Circle())
            }
        }
    }
    
    // MARK: - Selector estilo Mail
    private var selector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(Segment.allCases) { segment in
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selected = segment } }) {
                        HStack(spacing: selected == segment ? 10 : 0) {
                            Image(systemName: segment.icon)
                                .font(.system(.headline, design: .rounded, weight: .semibold))
                                .foregroundStyle(selected == segment ? .white : .secondary)
                            if selected == segment {
                                Text(segment.rawValue)
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, selected == segment ? 18 : 16)
                        .padding(.vertical, 14)
                        .frame(minWidth: selected == segment ? 140 : 56)
                        .background(
                            Group {
                                if selected == segment {
                                    Capsule()
                                        .fill(
                                            LinearGradient(colors: [Color.blue, Color.blue.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                } else {
                                    Capsule()
                                        .fill(.thinMaterial)
                                }
                            }
                        )
                        .shadow(color: (selected == segment ? Color.blue : Color.black).opacity(selected == segment ? 0.3 : 0.08), radius: selected == segment ? 10 : 6, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 6)
        }
    }
    
    // MARK: - Filtros secundarios (placeholder)
    private var filtersBar: some View {
        HStack(spacing: 10) {
            Menu {
                ForEach(Period.allCases) { p in
                    Button(action: { selectedPeriod = p }) {
                        HStack {
                            Text(p.rawValue)
                            if selectedPeriod == p { Spacer(); Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                    Text("Periodo: \(selectedPeriod.rawValue)")
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            
            Menu {
                Button(action: { selectedCategoryName = "Todas" }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("Todas")
                        if selectedCategoryName == "Todas" { Spacer(); Image(systemName: "checkmark") }
                    }
                }
                ForEach(combinedCategories, id: \.name) { item in
                    Button(action: { selectedCategoryName = item.name }) {
                        HStack {
                            Image(systemName: item.symbol)
                            Text(item.name)
                            if selectedCategoryName == item.name { Spacer(); Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: (selectedCategoryName == "Todas" ? "slider.horizontal.3" : symbolForCategory(selectedCategoryName)))
                    Text("Categorías: \(selectedCategoryName)")
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            Spacer()
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Contenido (por segmento)
    private var content: some View {
        VStack(spacing: 16) {
            if selected == .resumen {
                summaryView
            } else if selected == .transacciones {
                transactionsList
                    .padding(.top, 20)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: iconForSelected())
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(.blue)
                            Text(titleForSelected())
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundStyle(.primary)
                            Text("Aquí agregaremos gráficos y KPIs de \(selected.rawValue)")
                                .font(.system(.subheadline, design: .default))
                                .foregroundStyle(.secondary)
                        }
                    )
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var summaryView: some View {
        let expenses = filteredExpenses()
        return VStack(spacing: 16) {
            if expenses.isEmpty {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .frame(height: 180)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "rectangle.grid.2x2.fill")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(.blue)
                            Text("Resumen del periodo")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            Text("Aún no hay gastos en el periodo seleccionado")
                                .font(.system(.subheadline))
                                .foregroundStyle(.secondary)
                        }
                    )
            } else {
                // Totales por moneda
                let totals = totalsByCurrency(expenses)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "rectangle.grid.2x2.fill")
                            .foregroundStyle(.blue)
                        Text("Resumen del periodo")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(totals.keys.sorted(), id: \.self) { code in
                            HStack {
                                Image(systemName: symbolForCurrency(code))
                                Text("Total \(code):")
                                Spacer()
                                Text(formatAmount(totals[code] ?? 0, currencyCode: code))
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    Divider()
                    HStack {
                        Label("Transacciones", systemImage: "list.bullet")
                        Spacer()
                        Text("\(expenses.count)")
                            .fontWeight(.semibold)
                    }
                    if let top = topCategory(expenses) {
                        HStack {
                            Image(systemName: symbolForCategory(top.name))
                            Text("Top categoría:")
                            Text(top.name)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(formatAmount(top.total, currencyCode: top.currency))
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                .frame(maxWidth: .infinity)

                // Últimos gastos
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.blue)
                        Text("Últimos gastos")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                    }
                    VStack(spacing: 10) {
                        ForEach(Array(expenses.prefix(5)), id: \.id) { e in
                            HStack(spacing: 12) {
                                Image(systemName: symbolForCategory(e.category))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(e.title ?? e.category)
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    Text(shortDate(e.date))
                                        .font(.system(.caption, design: .default))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(formatAmount(e.amountInCents, currencyCode: e.currencyCode))
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            }
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func iconForSelected() -> String {
        switch selected {
        case .resumen: return "rectangle.grid.2x2.fill"
        case .transacciones: return "list.bullet"
        case .distribucion: return "chart.bar.fill"
        case .tendencia: return "chart.line.uptrend.xyaxis"
        }
    }
    
    private func titleForSelected() -> String {
        switch selected {
        case .resumen: return "Resumen del periodo"
        case .transacciones: return "Transacciones"
        case .distribucion: return "Distribución por categoría"
        case .tendencia: return "Tendencia"
        }
    }

    // MARK: - Transacciones
    private var transactionsList: some View {
        let expenses = filteredExpenses()
        return List {
            // Selector y filtros como primera sección
            Section {
                selector
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .padding(.bottom, 10)
                filtersBar
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
            }
            
            // Sección de contenido según segmento
            if selected == .transacciones {
                Section {
                    // Fila de encabezado "Transacciones" para igualar el estilo de Resumen
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundStyle(.blue)
                        Text("Transacciones")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        Spacer()
                        Text("\(expenses.count)")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.bottom, 8)
                    
                    if expenses.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(.blue)
                            Text("Aún no hay gastos en el periodo seleccionado")
                                .font(.system(.subheadline))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 32)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    } else {
                        ForEach(expenses, id: \.id) { e in
                            HStack(spacing: 12) {
                                Image(systemName: symbolForCategory(e.category))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(e.title ?? e.category)
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        .lineLimit(1)
                                    Text(shortDate(e.date))
                                        .font(.system(.caption, design: .default))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(formatAmount(e.amountInCents, currencyCode: e.currencyCode))
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .monospacedDigit()
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.ultraThinMaterial)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                            .padding(.vertical, 6)
                            .contextMenu {
                                Button(role: .destructive) { askDelete(e) } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) { askDelete(e) } label: {
                                    Image(systemName: "trash")
                                }
                                Button { startEditing(e) } label: {
                                    Image(systemName: "pencil")
                                }
                                .tint(.blue)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            } else if selected == .resumen {
                Section {
                    summaryView
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                        .frame(height: 220)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: iconForSelected())
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundStyle(.blue)
                                Text(titleForSelected())
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                                    .foregroundStyle(.primary)
                                Text("Aquí agregaremos gráficos y KPIs de \(selected.rawValue)")
                                    .font(.system(.subheadline, design: .default))
                                    .foregroundStyle(.secondary)
                            }
                        )
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .animation(.easeInOut(duration: 0.25), value: selected)
    }
    
    private func deleteExpense(_ expense: Expense) {
        modelContext.delete(expense)
        do {
            try modelContext.save()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            deleteErrorMessage = "No se pudo eliminar el gasto"
            showDeleteError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    private func askDelete(_ expense: Expense) {
        expensePendingDelete = expense
        showDeleteConfirm = true
    }
    
    private func startEditing(_ expense: Expense) {
        expenseToEdit = expense
    }
    
}

#Preview {
    SpendingDashboardView()
}

private extension SpendingDashboardView {
    func filteredExpenses() -> [Expense] {
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
            // Por ahora usamos mes actual; luego agregamos selector de rango
            let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        }
    }

    func totalsByCurrency(_ expenses: [Expense]) -> [String: Int] {
        var totals: [String: Int] = [:]
        for e in expenses { totals[e.currencyCode, default: 0] += e.amountInCents }
        return totals
    }

    func topCategory(_ expenses: [Expense]) -> (name: String, total: Int, currency: String)? {
        // Nota: mezcla monedas; tomamos la moneda más frecuente para mostrar
        var sums: [String: (total: Int, currency: String, count: Int)] = [:]
        for e in expenses { sums[e.category, default: (0, e.currencyCode, 0)].total += e.amountInCents; sums[e.category, default: (0, e.currencyCode, 0)].count += 1 }
        let sorted = sums.sorted { $0.value.total > $1.value.total }
        guard let first = sorted.first else { return nil }
        return (name: first.key, total: first.value.total, currency: first.value.currency)
    }

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
    var combinedCategories: [CategoryItem] {
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

    func symbolForCategory(_ name: String) -> String {
        if let item = PredefinedCategories.all.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return item.symbol
        }
        if let custom = customCategories.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return custom.symbol
        }
        return "tag.fill"
    }

    func shortDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_MX")
        df.setLocalizedDateFormatFromTemplate("d MMM yyyy, HH:mm")
        return df.string(from: date)
    }
}
