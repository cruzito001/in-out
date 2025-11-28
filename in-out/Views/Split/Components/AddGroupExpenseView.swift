//
//  AddGroupExpenseView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI
import SwiftData

struct AddGroupExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var group: SplitGroup
    
    @State private var title = ""
    @State private var amountText = ""
    @State private var paidBy: SplitMember?
    @State private var splitAmong: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalle del gasto") {
                    TextField("Concepto (ej. Cena)", text: $title)
                    HStack {
                        Text("$")
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Quién pagó") {
                    Picker("Pagado por", selection: $paidBy) {
                        Text("Seleccionar").tag(nil as SplitMember?)
                        ForEach(group.members) { member in
                            Text(member.name).tag(member as SplitMember?)
                        }
                    }
                }
                
                Section("Para quiénes") {
                    if group.members.isEmpty {
                        Text("Añade miembros al grupo primero")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(group.members) { member in
                            Button(action: { toggleSelection(member) }) {
                                HStack {
                                    Text(member.name)
                                    Spacer()
                                    if splitAmong.contains(member.id) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                        
                        Button("Seleccionar todos") {
                            splitAmong = Set(group.members.map { $0.id })
                        }
                        .font(.caption)
                        .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("Nuevo Gasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(!isValid)
                }
            }
            .onAppear {
                // Por defecto seleccionar todos
                if splitAmong.isEmpty {
                    splitAmong = Set(group.members.map { $0.id })
                }
                // Por defecto el primero paga si no hay nadie seleccionado
                if paidBy == nil, let first = group.members.first {
                    paidBy = first
                }
            }
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && (Double(amountText) ?? 0) > 0 && paidBy != nil && !splitAmong.isEmpty
    }
    
    private func toggleSelection(_ member: SplitMember) {
        if splitAmong.contains(member.id) {
            splitAmong.remove(member.id)
        } else {
            splitAmong.insert(member.id)
        }
    }
    
    private func save() {
        guard let amount = Double(amountText), let payer = paidBy else { return }
        
        let expense = SplitExpense(
            title: title,
            amount: amount,
            paidBy: payer,
            splitAmongIDs: Array(splitAmong)
        )
        
        group.expenses.append(expense)
        dismiss()
    }
}

