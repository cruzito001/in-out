//
//  DashboardFiltersView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct DashboardFiltersView: View {
    @ObservedObject var vm: DashboardViewModel
    let customCategories: [Category]
    
    var body: some View {
        HStack(spacing: 10) {
            Menu {
                ForEach(Period.allCases) { p in
                    Button(action: { vm.selectedPeriod = p }) {
                        HStack {
                            Text(p.rawValue)
                            if vm.selectedPeriod == p { Spacer(); Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                    Text("Periodo: \(vm.selectedPeriod.rawValue)")
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            
            Menu {
                Button(action: { vm.selectedCategoryName = "Todas" }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("Todas")
                        if vm.selectedCategoryName == "Todas" { Spacer(); Image(systemName: "checkmark") }
                    }
                }
                // Use VM helper
                ForEach(vm.combinedCategories(customCategories: customCategories), id: \.name) { item in
                    Button(action: { vm.selectedCategoryName = item.name }) {
                        HStack {
                            Image(systemName: item.symbol)
                            Text(item.name)
                            if vm.selectedCategoryName == item.name { Spacer(); Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: (vm.selectedCategoryName == "Todas" ? "slider.horizontal.3" : vm.symbolForCategory(vm.selectedCategoryName, customCategories: customCategories)))
                    Text("Categorías: \(vm.selectedCategoryName)")
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
}

