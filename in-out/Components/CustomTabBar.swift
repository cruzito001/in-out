//
//  CustomTabBar.swift
//  in-out
//
//  Created by Alan Joel Cruz Ortega on 04/09/25.
//

import SwiftUI

struct CustomTabBar: View {
    @State private var selectedTab = 0
    
    var body: some View {
        HStack(spacing: -30) {
            HStack(spacing: 0) {
                // Tab 1 - Gestión
                TabBarItem(
                    icon: "chart.pie.fill",
                    title: "Gestión",
                    isSelected: selectedTab == 0
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 0
                    }
                }
                
                // Tab 2 - División
                TabBarItem(
                    icon: "divide.circle.fill",
                    title: "División",
                    isSelected: selectedTab == 1
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 1
                    }
                }
                
                // Tab 3 - Ruleta
                TabBarItem(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Ruleta",
                    isSelected: selectedTab == 2
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 2
                    }
                }
            }
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 50)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            
            Spacer(minLength: 16)
            
            // Separador visual
            Rectangle()
                .fill(.quaternary)
                .frame(width: 1, height: 40)
                .padding(.horizontal, 8)
            
            Spacer(minLength: 16)
            
            // Tab de Configuración
            TabBarItem(
                icon: "gearshape.fill",
                title: "Config",
                isSelected: selectedTab == 3
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 3
                }
            }
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 50)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: -4)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(.title2, design: .default, weight: .medium))
                    .foregroundStyle(isSelected ? .blue : .secondary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(title)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(isSelected ? .blue : .secondary)
            }
            .frame(minWidth: 60)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                isSelected ? 
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                ) : 
                LinearGradient(
                    colors: [Color.clear, Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: RoundedRectangle(cornerRadius: 50)
            )
            .scaleEffect(isSelected ? 0.8 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar()
    }
    .background(
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.systemGroupedBackground),
                Color(.secondarySystemGroupedBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
