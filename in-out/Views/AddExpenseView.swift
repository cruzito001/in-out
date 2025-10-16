import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    enum Currency: String, CaseIterable, Identifiable {
        case mxn = "MXN"
        case usd = "USD"
        case eur = "EUR"
        var id: String { rawValue }
        var symbolImage: String {
            switch self {
            case .mxn: return "pesosign.circle.fill"
            case .usd: return "dollarsign.circle.fill"
            case .eur: return "eurosign.circle.fill"
            }
        }
        var flag: String {
            switch self {
            case .mxn: return "🇲🇽"
            case .usd: return "🇺🇸"
            case .eur: return "🇪🇺"
            }
        }
    }

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var date: Date = .init()
    @State private var category: String = "General"
    @State private var note: String = ""
    @State private var currency: Currency = .mxn
    @Query(sort: \Category.name) private var customCategories: [Category]

    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Título") {
                    TextField("Ej. Café, Supermercado, Uber", text: $title)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(false)
                }
                Section("Monto") {
                    HStack(spacing: 12) {
                        Menu {
                            ForEach(Currency.allCases) { c in
                                Button(action: { currency = c }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: c.symbolImage)
                                        Text(c.flag)
                                        Text(c.rawValue)
                                        if currency == c { Spacer(); Image(systemName: "checkmark") }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: currency.symbolImage)
                                Text(currency.flag)
                                Text(currency.rawValue)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: Capsule())
                        }
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                }

                Section("Fecha") {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                }

                Section("Categoría") {
                    Menu {
                        ForEach(combinedCategories, id: \.name) { item in
                            Button(action: { category = item.name }) {
                                HStack {
                                    Image(systemName: item.symbol)
                                    Text(item.name)
                                    if category == item.name { Spacer(); Image(systemName: "checkmark") }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: symbolForCategory(category))
                            Text(category)
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.thinMaterial, in: Capsule())
                    }
                }

                Section("Nota") {
                    TextField("Opcional", text: $note)
                }
            }
            .navigationTitle("Añadir gasto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(!isValid)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var isValid: Bool {
        guard let cents = parseAmountToCents(amountText) else { return false }
        return cents > 0
            && !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        guard let cents = parseAmountToCents(amountText) else {
            errorMessage = "Monto inválido"
            showingError = true
            return
        }
        let expense = Expense(
            amountInCents: cents,
            date: date,
            category: category,
            note: note.isEmpty ? nil : note,
            title: title.isEmpty ? nil : title,
            currencyCode: currency.rawValue
        )
        context.insert(expense)
        dismiss()
    }

    private func parseAmountToCents(_ text: String) -> Int? {
        let trimmed = text.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(trimmed) else { return nil }
        return Int((value * 100).rounded())
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(for: [Expense.self, Category.self], inMemory: true)
}

private extension AddExpenseView {
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
}
