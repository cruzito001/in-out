//
//  BalanceView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct BalanceView: View {
    let group: SplitGroup
    
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
        
        ScrollView {
            VStack(spacing: 24) {
                if group.members.isEmpty {
                    ContentUnavailableView("Sin miembros", systemImage: "person.3", description: Text("Añade miembros para calcular balances"))
                } else if group.expenses.isEmpty {
                    ContentUnavailableView("Todo en orden", systemImage: "checkmark.circle", description: Text("No hay gastos registrados"))
                } else {
                    // 1. Gráfico de Barras (Resumen Neto)
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
                    
                    // 2. Instrucciones de Pago (Tarjetas)
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
                                    VStack(spacing: 2) {
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
                    } else if !group.expenses.isEmpty {
                        // Caso raro: hay gastos pero todo cuadra perfecto (ej. yo pagué lo mío)
                        ContentUnavailableView("Cuentas Saldadas", systemImage: "checkmark.seal.fill", description: Text("Nadie debe nada a nadie."))
                    }
                }
            }
            .padding(.top)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Logic
    
    private func calculateDirectDebts() -> ([Debt], [MemberBalance]) {
        var balances: [UUID: Double] = [:]
        // Matriz de deudas: [DeudorID: [AcreedorID: Monto]]
        var debtMatrix: [UUID: [UUID: Double]] = [:]
        
        // Inicializar
        for member in group.members {
            balances[member.id] = 0.0
            debtMatrix[member.id] = [:]
        }
        
        // 1. Calcular deudas directas por cada gasto
        for expense in group.expenses {
            guard let payer = expense.paidBy else { continue }
            let beneficiaries = expense.splitAmongMemberIDs
            
            guard !beneficiaries.isEmpty else { continue }
            let splitAmount = expense.amount / Double(beneficiaries.count)
            
            for beneficiaryID in beneficiaries {
                if beneficiaryID == payer.id {
                    // Si pagué por mí mismo, no hay deuda, solo afecta mi balance "teórico" de gasto
                    continue
                }
                
                // El beneficiario LE DEBE al pagador
                // Sumamos a la deuda existente entre este par
                debtMatrix[beneficiaryID, default: [:]][payer.id, default: 0] += splitAmount
            }
        }
        
        // 2. Simplificar deudas bidireccionales (Netting par a par)
        // Si A debe 100 a B, y B debe 40 a A -> A debe 60 a B
        var finalDebts: [Debt] = []
        
        let memberIDs = group.members.map { $0.id }
        var processedPairs = Set<String>() // Para no procesar A-B y luego B-A
        
        for i in 0..<memberIDs.count {
            for j in (i+1)..<memberIDs.count {
                let idA = memberIDs[i]
                let idB = memberIDs[j]
                
                let debtAtoB = debtMatrix[idA]?[idB] ?? 0
                let debtBtoA = debtMatrix[idB]?[idA] ?? 0
                
                let net = debtAtoB - debtBtoA
                
                if net > 0.01 {
                    // A le debe a B el neto
                    if let debtor = group.members.first(where: { $0.id == idA }),
                       let creditor = group.members.first(where: { $0.id == idB }) {
                        finalDebts.append(Debt(debtor: debtor, creditor: creditor, amount: net))
                    }
                } else if net < -0.01 {
                    // B le debe a A el neto (positivo)
                    if let debtor = group.members.first(where: { $0.id == idB }),
                       let creditor = group.members.first(where: { $0.id == idA }) {
                        finalDebts.append(Debt(debtor: debtor, creditor: creditor, amount: abs(net)))
                    }
                }
            }
        }
        
        // 3. Calcular balances globales para el gráfico
        // Esto es simplemente la suma de lo que he pagado vs lo que he consumido globalmente
        // O podemos derivarlo de las deudas finales para que cuadre visualmente:
        // Balance = (Lo que me deben) - (Lo que debo)
        
        var finalBalances: [MemberBalance] = []
        
        for member in group.members {
            var amount = 0.0
            
            // Sumar lo que me deben (soy acreedor)
            let incoming = finalDebts.filter { $0.creditor.id == member.id }.reduce(0) { $0 + $1.amount }
            // Restar lo que debo (soy deudor)
            let outgoing = finalDebts.filter { $0.debtor.id == member.id }.reduce(0) { $0 + $1.amount }
            
            amount = incoming - outgoing
            finalBalances.append(MemberBalance(member: member, amount: amount))
        }
        
        // Ordenar balances: Mayor ganancia arriba
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
