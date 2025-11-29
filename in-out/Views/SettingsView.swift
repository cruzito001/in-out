//
//  SettingsView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - App Storage
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("appVersion") private var appVersion: String = "1.0.0"
    
    // MARK: - Data Queries
    @Query private var allExpenses: [Expense]
    @Query private var allGroups: [SplitGroup]
    
    // MARK: - State
    @State private var showDeleteAlert = false
    @State private var deleteTarget: DeleteTarget = .expenses
    
    enum DeleteTarget {
        case expenses
        case groups
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Header Principal (Estilo Dashboard)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Configuración")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            Text("Preferencias y datos")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        
                        Image(systemName: "gear")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.gradient, in: Circle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // MARK: - Lista de Opciones
                    List {
                        // MARK: - Preferencias
                        Section {
                            // Toggle Haptics
                            Toggle(isOn: $enableHaptics) {
                                SettingsLabel(icon: "iphone.gen3", color: .indigo, title: "Vibración (Haptics)")
                            }
                        } header: {
                            Text("General")
                        } footer: {
                            Text("Activa la respuesta háptica para sentir vibraciones en la Ruleta y botones.")
                        }
                        
                        // MARK: - Datos
                        Section("Datos") {
                            if allExpenses.isEmpty {
                                ContentUnavailableView("Sin datos para exportar", systemImage: "list.bullet.clipboard")
                                    .frame(height: 80)
                                    .listRowBackground(Color.clear)
                            } else {
                                ShareLink(item: generateCSV(), preview: SharePreview("Gastos in-out", image: Image(systemName: "tablecells"))) {
                                    HStack {
                                        SettingsLabel(icon: "square.and.arrow.up.fill", color: .blue, title: "Exportar Gastos (CSV)")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption.bold())
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        
                        // MARK: - Zona de Peligro
                        Section {
                            Button(role: .destructive) {
                                deleteTarget = .expenses
                                showDeleteAlert = true
                            } label: {
                                SettingsLabel(icon: "trash.fill", color: .red, title: "Borrar todos los Gastos")
                                    .foregroundStyle(.red)
                            }
                            
                            Button(role: .destructive) {
                                deleteTarget = .groups
                                showDeleteAlert = true
                            } label: {
                                SettingsLabel(icon: "person.3.fill", color: .orange, title: "Borrar todos los Grupos")
                                    .foregroundStyle(.red)
                            }
                        } header: {
                            Text("Zona de Peligro")
                        } footer: {
                            Text("Estas acciones no se pueden deshacer.")
                        }
                        
                        // MARK: - Acerca de
                        Section {
                            HStack {
                                SettingsLabel(icon: "info.circle.fill", color: .gray, title: "Versión")
                                Spacer()
                                Text(appVersion)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Link(destination: URL(string: "https://github.com/cruzito001?tab=repositories")!) {
                                HStack {
                                    SettingsLabel(icon: "hammer.fill", color: .purple, title: "Desarrollador")
                                    Spacer()
                                    Text("Alan Cruz")
                                        .foregroundStyle(.secondary)
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .foregroundStyle(.primary)
                        } header: {
                            Text("Información")
                        }
                    }
                    .scrollContentBackground(.hidden) // Para que se vea el fondo del ZStack
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                switch deleteTarget {
                case .expenses:
                    return Alert(
                        title: Text("¿Borrar Gastos?"),
                        message: Text("Esta acción eliminará \(allExpenses.count) registros de gastos permanentemente."),
                        primaryButton: .destructive(Text("Eliminar")) { deleteAllExpenses() },
                        secondaryButton: .cancel()
                    )
                case .groups:
                    return Alert(
                        title: Text("¿Borrar Grupos?"),
                        message: Text("Esta acción eliminará \(allGroups.count) grupos y su historial."),
                        primaryButton: .destructive(Text("Eliminar")) { deleteAllGroups() },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    // Componente auxiliar para estilo "iOS Settings"
    private struct SettingsLabel: View {
        let icon: String
        let color: Color
        let title: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(color.gradient, in: RoundedRectangle(cornerRadius: 6))
                
                Text(title)
            }
        }
    }
    
    // MARK: - Logic
    
    private func generateCSV() -> String {
        var csvString = "Fecha,Concepto,Monto,Categoría\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        for expense in allExpenses {
            let date = dateFormatter.string(from: expense.date)
            
            let safeTitle = expense.title ?? "Gasto"
            let title = safeTitle.contains(",") ? "\"\(safeTitle)\"" : safeTitle
            
            let amountValue = Double(expense.amountInCents) / 100.0
            let amount = String(format: "%.2f", amountValue)
            
            let catString = expense.category
            let category = catString.contains(",") ? "\"\(catString)\"" : catString
            
            csvString.append("\(date),\(title),\(amount),\(category)\n")
        }
        
        return csvString
    }
    
    private func deleteAllExpenses() {
        withAnimation {
            for expense in allExpenses {
                modelContext.delete(expense)
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    private func deleteAllGroups() {
        withAnimation {
            for group in allGroups {
                modelContext.delete(group)
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

#Preview {
    SettingsView()
}
