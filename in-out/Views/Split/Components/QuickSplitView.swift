//
//  QuickSplitView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct QuickSplitView: View {
    // MARK: - State
    @State private var totalAmount: String = ""
    @State private var numberOfPeople: Double = 2
    @State private var tipPercentage: Int = 10
    @State private var showSaveSheet: Bool = false
    @FocusState private var isInputFocused: Bool
    
    // MARK: - Computed
    var totalAmountValue: Double {
        Double(totalAmount) ?? 0
    }
    
    var tipAmount: Double {
        totalAmountValue * (Double(tipPercentage) / 100.0)
    }
    
    var grandTotal: Double {
        totalAmountValue + tipAmount
    }
    
    var amountPerPerson: Double {
        guard numberOfPeople > 0 else { return 0 }
        return grandTotal / numberOfPeople
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {
            // 1. Tarjeta de Entrada
            VStack(spacing: 20) {
                // Monto Total
                VStack(spacing: 8) {
                    Text("Monto de la cuenta")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        TextField("0", text: $totalAmount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .focused($isInputFocused)
                            .frame(minWidth: 80)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                
                Divider()
                
                // Selector de Personas
                VStack(spacing: 12) {
                    HStack {
                        Text("Personas")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(numberOfPeople))")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(.blue)
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: { if numberOfPeople > 1 { numberOfPeople -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(value: $numberOfPeople, in: 1...20, step: 1)
                            .tint(.blue)
                        
                        Button(action: { if numberOfPeople < 50 { numberOfPeople += 1 } }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Selector de Propina
                VStack(spacing: 12) {
                    HStack {
                        Text("Propina")
                            .font(.headline)
                        Spacer()
                        Text("\(tipPercentage)%")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(.blue)
                    }
                    
                    Picker("Propina", selection: $tipPercentage) {
                        Text("0%").tag(0)
                        Text("10%").tag(10)
                        Text("15%").tag(15)
                        Text("20%").tag(20)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding(20)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .onTapGesture { isInputFocused = false }
            
            // 2. Resultados
            VStack(spacing: 16) {
                Text("Cada uno paga")
                    .font(.subheadline)
                    .foregroundStyle(.secondary.opacity(0.8))
                
                Text(formatCurrency(amountPerPerson))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    // Sombra sutil para destacar sobre fondo oscuro
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Cuenta")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(totalAmountValue))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    
                    Divider().frame(height: 30)
                    
                    VStack(spacing: 4) {
                        Text("Propina")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(tipAmount))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    
                    Divider().frame(height: 30)
                    
                    VStack(spacing: 4) {
                        Text("Total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(grandTotal))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.indigo.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 10)
            
            // 3. Acciones
            HStack(spacing: 16) {
                // Botón Compartir (Visual)
                Button(action: shareResult) {
                    VStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                        Text("Compartir")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(width: 80, height: 60)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                
                // Botón Guardar Mi Parte
                Button(action: { showSaveSheet = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Guardar mi parte")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.white)
                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
        .fullScreenCover(isPresented: $showSaveSheet) {
            AddExpenseView(initialAmount: amountPerPerson)
                .presentationBackground(.thinMaterial)
        }
    }
    
    // MARK: - Helpers
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    @MainActor
    private func shareResult() {
        let text = """
        🧾 División de Cuenta
        
        Total: \(formatCurrency(grandTotal))
        Personas: \(Int(numberOfPeople))
        
        👉 Nos toca de: \(formatCurrency(amountPerPerson)) c/u
        """
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            // En iPad necesita sourceView
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true)
        }
    }
}

