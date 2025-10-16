import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var symbol: String = "tag.fill"
    @FocusState private var nameFocused: Bool
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""

    @Query(sort: \Category.name) private var existingCategories: [Category]

    private var suggestedSymbols: [String] {
        var base = PredefinedCategories.all.map { $0.symbol }
        base.append(contentsOf: [
            "cart.fill", "house.fill", "car.fill", "fork.knife",
            "airplane", "creditcard.fill", "gift.fill", "gamecontroller.fill",
            "tshirt.fill", "leaf.fill", "sparkles", "cup.and.saucer.fill",
            "bolt.fill", "tram.fill", "banknote.fill"
        ])
        return Array(Set(base)).sorted()
    }

    private var canSave: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let existsInPredef = PredefinedCategories.all.map { $0.name.lowercased() }.contains(trimmed.lowercased())
        let existsCustom = existingCategories.map { $0.name.lowercased() }.contains(trimmed.lowercased())
        return !existsInPredef && !existsCustom
    }

    private var duplicateReason: String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if PredefinedCategories.all.map({ $0.name.lowercased() }).contains(trimmed.lowercased()) {
            return "Ese nombre ya existe en las categorías predefinidas"
        }
        if existingCategories.map({ $0.name.lowercased() }).contains(trimmed.lowercased()) {
            return "Ese nombre ya existe en tus categorías"
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        TextField("Ej. Supermercado", text: $name)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .focused($nameFocused)
                            .padding()
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        if let reason = duplicateReason {
                            Text(reason)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ícono")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                            ForEach(suggestedSymbols, id: \.self) { sym in
                                Button {
                                    symbol = sym
                                } label: {
                                    Image(systemName: sym)
                                        .frame(width: 36, height: 36)
                                        .background(symbol == sym ? Color.blue.opacity(0.15) : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }

                    Spacer(minLength: 0)
                }
                .padding(20)
            }
            .navigationTitle("Añadir categoría")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        let new = Category(name: trimmed, symbol: symbol)
                        modelContext.insert(new)
                        do {
                            try modelContext.save()
                        } catch {
                            errorMessage = "No se pudo guardar la categoría: \(error.localizedDescription)"
                            showingError = true
                            return
                        }
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear { nameFocused = true }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    AddCategoryView()
        .modelContainer(for: [Category.self], inMemory: true)
}