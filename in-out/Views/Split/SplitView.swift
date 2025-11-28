//
//  SplitView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct SplitView: View {
    @StateObject private var vm = SplitViewModel()
    
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
            
            ScrollView {
                VStack(spacing: 20) {
                    selector
                        .padding(.top, 10)
                    
                    // Contenido Dinámico
                    switch vm.selectedTab {
                    case .quick:
                        QuickSplitView()
                    case .group:
                        placeholderView(title: "Grupal", icon: "person.3.fill", description: "Gestiona cuentas complejas con múltiples personas.")
                    case .saved:
                        placeholderView(title: "Guardados", icon: "bookmark.fill", description: "Historial de divisiones guardadas.")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .top) {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dividir Cuenta")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                Text("Reparte gastos fácilmente")
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
    
    private var selector: some View {
        HStack(spacing: 0) {
            ForEach(SplitViewModel.SplitTab.allCases) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        vm.selectedTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .semibold))
                        Text(tab.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundStyle(vm.selectedTab == tab ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        if vm.selectedTab == tab {
                            Capsule()
                                .fill(Color.blue)
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                .matchedGeometryEffect(id: "SplitTab", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(.thinMaterial, in: Capsule())
    }
    
    @Namespace private var namespace
    
    private func placeholderView(title: String, icon: String, description: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.blue.opacity(0.8))
                .padding(.bottom, 8)
            
            Text(title)
                .font(.system(.title2, design: .rounded, weight: .bold))
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding(.top, 20)
    }
}

#Preview {
    SplitView()
}
