//
//  ArchivedGroupsView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI
import SwiftData

struct ArchivedGroupsView: View {
    @Query(filter: #Predicate<SplitGroup> { $0.isArchived == true }, sort: \SplitGroup.date, order: .reverse)
    private var archivedGroups: [SplitGroup]
    @Environment(\.modelContext) private var context
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.clear
                
                if archivedGroups.isEmpty {
                    ContentUnavailableView("Sin Archivos", systemImage: "archivebox", description: Text("Aquí aparecerán los grupos que hayas saldado y archivado."))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(archivedGroups) { group in
                                GroupCard(group: group)
                                    .opacity(0.8) // Visualmente distinto
                                    .grayscale(0.5)
                                    .onTapGesture {
                                        path.append(group)
                                    }
                                    .contextMenu {
                                        Button {
                                            reactivateGroup(group)
                                        } label: {
                                            Label("Reactivar", systemImage: "arrow.uturn.left")
                                        }
                                        
                                        Button(role: .destructive) {
                                            context.delete(group)
                                        } label: {
                                            Label("Eliminar Definitivamente", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }
            .navigationDestination(for: SplitGroup.self) { group in
                GroupDetailView(group: group)
            }
        }
    }
    
    private func reactivateGroup(_ group: SplitGroup) {
        group.isArchived = false
    }
}

