//
//  DashboardSelectorView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct DashboardSelectorView: View {
    @ObservedObject var vm: DashboardViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(Segment.allCases) { segment in
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { vm.selected = segment } }) {
                        HStack(spacing: vm.selected == segment ? 10 : 0) {
                            Image(systemName: segment.icon)
                                .font(.system(.headline, design: .rounded, weight: .semibold))
                                .foregroundStyle(vm.selected == segment ? .white : .secondary)
                            if vm.selected == segment {
                                Text(segment.rawValue)
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, vm.selected == segment ? 18 : 16)
                        .padding(.vertical, 14)
                        .frame(minWidth: vm.selected == segment ? 140 : 56)
                        .background(
                            Group {
                                if vm.selected == segment {
                                    Capsule()
                                        .fill(
                                            LinearGradient(colors: [Color.blue, Color.blue.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                } else {
                                    Capsule()
                                        .fill(.thinMaterial)
                                }
                            }
                        )
                        .shadow(color: (vm.selected == segment ? Color.blue : Color.black).opacity(vm.selected == segment ? 0.3 : 0.08), radius: vm.selected == segment ? 10 : 6, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 6)
        }
    }
}

