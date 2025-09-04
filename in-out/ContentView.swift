//
//  ContentView.swift
//  in-out
//
//  Created by Alan Joel Cruz Ortega on 29/08/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingRegister = false
    
    var body: some View {
        if showingRegister {
            RegisterView(showingRegister: $showingRegister)
        } else {
            LoginView(showingRegister: $showingRegister)
        }
    }
}

#Preview {
    ContentView()
}
