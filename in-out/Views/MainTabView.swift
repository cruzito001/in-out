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
        ZStack {
            switch selectedTab {
            case 0, 1:
                ComingSoonView()
            case 2:
                RouletteCardsView()
            case 3:
                SettingsView()
            default:
                ComingSoonView()
            }
            
            // CustomTabBar en la parte inferior
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, 34)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    MainTabView()
}