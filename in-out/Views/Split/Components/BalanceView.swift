//
//  BalanceView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI
import SwiftData

struct BalanceView: View {
    let group: SplitGroup
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    struct Debt: Identifiable {
        let id = UUID()
        let debtor: SplitMember
        let creditor: SplitMember
        let amount: Double
    }
    
    struct MemberBalance: Identifiable {
        let id = UUID()
        let member: SplitMember
        let amount: Double // Positivo: le deben, Negativo: debe
    }
    
    var body: some View {
        let (rawDebts, balances) = calculateDirectDebts()
        // Agrupar visualmente ordenando por deudor
        let debts = rawDebts.sorted {
            if $0.debtor.name == $1.debtor.name {
                return $0.creditor.name < $1.creditor.name
            }
            return $0.debtor.name < $1.debtor.name
        }
        let maxBalance = balances.map { abs($0.amount) }.max() ?? 1.0
        let allSettled = debts.isEmpty && !group.expenses.isEmpty
        
        // Identificar reembolsos
        let reimbursements = group.expenses.filter { $0.title.hasPrefix("Reembolso a") }.sorted(by: { $0.date > $1.date })
        
        ScrollView {
            VStack(spacing: 24) {
                if group.members.isEmpty {
                    ContentUnavailableView("Sin miembros", systemImage: "person.3", description: Text("Añade miembros para calcular balances"))
                } else if group.expenses.isEmpty {
                    ContentUnavailableView("Todo en orden", systemImage: "checkmark.circle", description: Text("No hay gastos registrados"))
                } else {
                    // 1. Gráfico de Barras (Resumen Neto)
                    if !balances.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Estado General")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(balances) { item in
                                    HStack {
                                        // Avatar y Nombre
                                        HStack(spacing: 8) {
                                            Text(String(item.member.name.prefix(1)))
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                                .frame(width: 24, height: 24)
                                                .background(Color(hex: item.member.colorHex) ?? .gray, in: Circle())
                                            Text(item.member.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .lineLimit(1)
                                        }
                                        .frame(width: 100, alignment: .leading)
                                        
                                        // Barra Visual
                                        GeometryReader { geo in
                                            let width = geo.size.width
                                            let zeroX = width / 2
                                            let barLength = (abs(item.amount) / maxBalance) * (width / 2) * 0.9
                                            
                                            ZStack(alignment: .leading) {
                                                // Línea central
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(width: 1, height: 20)
                                                    .position(x: zeroX, y: 10)
                                                
                                                // Barra
                                                if item.amount > 0.01 {
                                                    // Verde (A favor / Recibe) -> Hacia la derecha
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.green.gradient)
                                                        .frame(width: barLength, height: 12)
                                                        .position(x: zeroX + barLength/2, y: 10)
                                                } else if item.amount < -0.01 {
                                                    // Rojo (Debe) -> Hacia la izquierda
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.red.gradient)
                                                        .frame(width: barLength, height: 12)
                                                        .position(x: zeroX - barLength/2, y: 10)
                                                } else {
                                                    // Saldado
                                                    Circle()
                                                        .fill(Color.gray.opacity(0.3))
                                                        .frame(width: 8, height: 8)
                                                        .position(x: zeroX, y: 10)
                                                }
                                            }
                                        }
                                        .frame(height: 20)
                                        
                                        // Monto
                                        Text(formatCurrency(abs(item.amount)))
                                            .font(.caption.bold())
                                            .monospacedDigit()
                                            .foregroundStyle(item.amount > 0.01 ? .green : (item.amount < -0.01 ? .red : .secondary))
                                            .frame(width: 70, alignment: .trailing)
                                    }
                                }
                            }
                            .padding()
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                        }
                    }
                    
                    // 2. Instrucciones de Pago (Tarjetas Activas)
                    if !debts.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Pagos Sugeridos")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(debts) { debt in
                                HStack(spacing: 0) {
                                    // Deudor
                                    VStack(spacing: 4) {
                                        Text(String(debt.debtor.name.prefix(1)))
                                            .font(.title3.bold())
                                            .foregroundStyle(.white)
                                            .frame(width: 44, height: 44)
                                            .background(Color(hex: debt.debtor.colorHex) ?? .red, in: Circle())
                                        Text(debt.debtor.name)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .frame(width: 70)
                                    
                                    // Flecha y Monto
                                    VStack(spacing: 6) {
                                        Text("paga")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        
                                        HStack(spacing: 0) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                            
                                            Text(formatCurrency(debt.amount))
                                                .font(.callout.bold())
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.1), in: Capsule())
                                                .foregroundStyle(.blue)
                                            
                                            Image(systemName: "arrow.right")
                                                .font(.caption)
                                                .foregroundStyle(.gray.opacity(0.5))
                                        }
                                        
                                        Button("Marcar Pagado") {
                                            withAnimation {
                                                settleDebt(debt)
                                            }
                                        }
                                        .font(.caption.bold())
                                        .buttonStyle(.bordered)
                                        .buttonBorderShape(.capsule)
                                        .tint(.green)
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    // Acreedor
                                    VStack(spacing: 4) {
                                        Text(String(debt.creditor.name.prefix(1)))
                                            .font(.title3.bold())
                                            .foregroundStyle(.white)
                                            .frame(width: 44, height: 44)
                                            .background(Color(hex: debt.creditor.colorHex) ?? .green, in: Circle())
                                        Text(debt.creditor.name)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .frame(width: 70)
                                }
                                .padding()
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 3. Estado Saldado y Archivar (Solo si todo está saldado)
                    if allSettled {
                        VStack(spacing: 20) {
                            Image(systemName: "party.popper.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.yellow)
                                .symbolEffect(.bounce)
                            
                            Text("¡Todo Saldado!")
                                .font(.title.bold())
                            
                            Text("Nadie debe nada a nadie. Puedes archivar este grupo para guardarlo en el historial.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                            
                            Button(action: archiveGroup) {
                                Label("Archivar Grupo", systemImage: "archivebox.fill")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 16))
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.vertical, 40)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
                        .padding()
                    }
                    
                    // 4. Historial de Pagos (Saldados) - DESHACER
                    if !reimbursements.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Pagos Realizados")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                            
                            ForEach(reimbursements) { expense in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green.opacity(0.6))
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(expense.title) // Ej. "Reembolso a Lalo"
                                            .foregroundStyle(.secondary)
                                            .strikethrough()
                                        
                                        if let payer = expense.paidBy {
                                            Text("Pagado por \(payer.name)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary.opacity(0.7))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text(formatCurrency(expense.amount))
                                        .foregroundStyle(.secondary)
                                        .strikethrough()
                                        .monospacedDigit()
                                    
                                    Button(role: .destructive) {
                                        withAnimation {
                                            undoPayment(expense)
                                        }
                                    } label: {
                                        Image(systemName: "arrow.uturn.backward.circle.fill")
                                            .foregroundStyle(.gray)
                                            .font(.title2)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        .foregroundStyle(Color.gray.opacity(0.3))
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.top)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Logic
    
    private func settleDebt(_ debt: Debt) {
        let expense = SplitExpense(
            title: "Reembolso a \(debt.creditor.name)",
            amount: debt.amount,
            paidBy: debt.debtor,
            splitAmongIDs: [debt.creditor.id]
        )
        group.expenses.append(expense)
    }
    
    private func undoPayment(_ expense: SplitExpense) {
        if let index = group.expenses.firstIndex(where: { $0.id == expense.id }) {
            group.expenses.remove(at: index)
            context.delete(expense)
        }
    }
    
    private func archiveGroup() {
        group.isArchived = true
        dismiss() // Volver a la lista
    }
    
    private func calculateDirectDebts() -> ([Debt], [MemberBalance]) {
        var balances: [UUID: Double] = [:]
        var debtMatrix: [UUID: [UUID: Double]] = [:]
        
        for member in group.members {
            balances[member.id] = 0.0
            debtMatrix[member.id] = [:]
        }
        
        for expense in group.expenses {
            guard let payer = expense.paidBy else { continue }
            let amount = expense.amount
            let beneficiaries = expense.splitAmongMemberIDs
            
            guard !beneficiaries.isEmpty else { continue }
            let splitAmount = amount / Double(beneficiaries.count)
            
            balances[payer.id, default: 0] += amount
            
            for beneficiaryID in beneficiaries {
                balances[beneficiaryID, default: 0] -= splitAmount
                
                if beneficiaryID == payer.id {
                    continue
                }
                
                debtMatrix[beneficiaryID, default: [:]][payer.id, default: 0] += splitAmount
            }
        }
        
        var finalDebts: [Debt] = []
        let memberIDs = group.members.map { $0.id }
        
        for i in 0..<memberIDs.count {
            for j in (i+1)..<memberIDs.count {
                let idA = memberIDs[i]
                let idB = memberIDs[j]
                
                let debtAtoB = debtMatrix[idA]?[idB] ?? 0
                let debtBtoA = debtMatrix[idB]?[idA] ?? 0
                
                let net = debtAtoB - debtBtoA
                
                if net > 0.01 {
                    if let debtor = group.members.first(where: { $0.id == idA }),
                       let creditor = group.members.first(where: { $0.id == idB }) {
                        finalDebts.append(Debt(debtor: debtor, creditor: creditor, amount: net))
                    }
                } else if net < -0.01 {
                    if let debtor = group.members.first(where: { $0.id == idB }),
                       let creditor = group.members.first(where: { $0.id == idA }) {
                        finalDebts.append(Debt(debtor: debtor, creditor: creditor, amount: abs(net)))
                    }
                }
            }
        }
        
        var finalBalances: [MemberBalance] = []
        for member in group.members {
            let amount = balances[member.id] ?? 0
            finalBalances.append(MemberBalance(member: member, amount: amount))
        }
        
        finalBalances.sort { $0.amount > $1.amount }
        
        return (finalDebts, finalBalances)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
