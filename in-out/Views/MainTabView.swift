//
//  MainTabView.swift
//  in-out
//
//  Created by Alan Joel Cruz Ortega on 04/09/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            SpendingDashboardView()
                .tabItem {
                    Label("Gestión", systemImage: "chart.pie.fill")
                }
                .tag(0)

            ComingSoonView()
                .tabItem {
                    Label("División", systemImage: "divide.circle.fill")
                }
                .tag(1)

            RouletteCardsView()
                .tabItem {
                    Label("Ruleta", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Config", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    MainTabView()
}