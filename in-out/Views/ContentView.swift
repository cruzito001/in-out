//
//  ContentView.swift
//  in-out
//
//  Created by Alan Joel Cruz Ortega on 29/08/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingRegister = false
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            if showingRegister {
                RegisterView(showingRegister: $showingRegister, isLoggedIn: $isLoggedIn)
            } else {
                LoginView(showingRegister: $showingRegister, isLoggedIn: $isLoggedIn)
            }
        }
    }
}

#Preview {
    ContentView()
}
