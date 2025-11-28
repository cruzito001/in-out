//
//  SplitViewModel.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

class SplitViewModel: ObservableObject {
    
    enum SplitTab: String, CaseIterable, Identifiable {
        case quick = "Cálculo Rápido"
        case group = "Grupal"
        case saved = "Guardados"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .quick: return "bolt.fill"
            case .group: return "person.3.fill"
            case .saved: return "bookmark.fill"
            }
        }
    }
    
    @Published var selectedTab: SplitTab = .quick
    
}

