//
//  DashboardHeaderView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct DashboardHeaderView: View {
    @ObservedObject var vm: DashboardViewModel
    let expensesCount: Int
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Control de gastos")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                Text("Actualizado justo ahora • \(expensesCount == 1 ? "1 gasto" : "\(expensesCount) gastos")")
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            
            // Botón de Búsqueda
            Button(action: { vm.showSearch = true }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(10)
                    .background(.thinMaterial, in: Circle())
            }
            
            Menu {
                Button(action: { vm.showAddSheet = true }) {
                    Label("Agregar gasto", systemImage: "plus.circle")
                }
                Button(action: { vm.showAddCategorySheet = true }) {
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
}

