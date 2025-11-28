//
//  GroupListView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI
import SwiftData

struct GroupListView: View {
    @Query(filter: #Predicate<SplitGroup> { $0.isArchived == false }, sort: \SplitGroup.date, order: .reverse) private var groups: [SplitGroup]
    @Environment(\.modelContext) private var context
    @State private var showAddGroupSheet = false
    @State private var newGroupName = ""
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Fondo transparente para ver el gradiente padre si es necesario
                Color.clear
                
                if groups.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(groups) { group in
                                GroupCard(group: group)
                                    .onTapGesture {
                                        path.append(group)
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            context.delete(group)
                                        } label: {
                                            Label("Eliminar", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 100) // Espacio para el botón flotante
                    }
                }
            }
            .navigationDestination(for: SplitGroup.self) { group in
                GroupDetailView(group: group)
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: { showAddGroupSheet = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue, in: Circle())
                        .shadow(radius: 4, y: 2)
                }
                .padding(20)
            }
            .alert("Nuevo Grupo", isPresented: $showAddGroupSheet) {
                TextField("Nombre del evento", text: $newGroupName)
                Button("Cancelar", role: .cancel) { newGroupName = "" }
                Button("Crear") {
                    if !newGroupName.isEmpty {
                        let newGroup = SplitGroup(name: newGroupName)
                        context.insert(newGroup)
                        newGroupName = ""
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary.opacity(0.5))
            Text("No hay grupos activos")
                .font(.title3.bold())
                .foregroundStyle(.primary) // Cambiado a primary para mejor visibilidad
            Text("Crea un evento para empezar a dividir gastos con tus amigos.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // .background(Color.red.opacity(0.1)) // Debugging: descomentar si sigue invisible
    }
}

struct GroupCard: View {
    let group: SplitGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(group.name)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                Spacer()
                Text(shortDate(group.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                if group.members.isEmpty {
                    Text("Sin miembros aún")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    HStack(spacing: -8) {
                        ForEach(group.members.prefix(5)) { member in
                            Text(String(member.name.prefix(1)))
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 28, height: 28)
                                .background(Color(hex: member.colorHex) ?? .gray, in: Circle())
                                .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                        }
                        if group.members.count > 5 {
                            Text("+\(group.members.count - 5)")
                                .font(.caption2)
                                .frame(width: 28, height: 28)
                                .background(.thinMaterial, in: Circle())
                                .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                        }
                    }
                }
                Spacer()
                Text("\(group.expenses.count) gastos")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func shortDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_MX")
        df.setLocalizedDateFormatFromTemplate("d MMM")
        return df.string(from: date)
    }
}

// Helper para Color Hex
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
