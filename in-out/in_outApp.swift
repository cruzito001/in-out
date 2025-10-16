//
//  in_outApp.swift
//  in-out
//
//  Created by Alan Joel Cruz Ortega on 29/08/25.
//

import SwiftUI
import UIKit

@main
struct in_outApp: App {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
        appearance.shadowColor = nil
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
