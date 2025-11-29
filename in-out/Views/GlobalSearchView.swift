//
//  GlobalSearchView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI
import SwiftData

struct GlobalSearchView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var searchText = ""
    
    // Consultas SwiftData (Traemos todo para filtrar en memoria por simplicidad y reactividad)
    // Nota: En bases de datos muy grandes esto se optimizaría con Predicados dinámicos.
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \SplitGroup.date, order: .reverse) private var groups: [SplitGroup]
    @Query(sort: \Category.name) private var categories: [Category]
    
    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    emptyState
                } else {
                    searchResults
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Buscar gastos, grupos, categorías...")
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var emptyState: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary.opacity(0.5))
                Text("Escribe para buscar")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .listRowBackground(Color.clear)
        }
    }
    
    private var searchResults: some View {
        Group {
            // 1. Grupos
            let foundGroups = groups.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            if !foundGroups.isEmpty {
                Section("Grupos") {
                    ForEach(foundGroups) { group in
                        NavigationLink(destination: GroupDetailView(group: group)) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundStyle(.orange)
                                    .frame(width: 24)
                                VStack(alignment: .leading) {
                                    Text(group.name)
                                        .font(.headline)
                                    Text("\(group.members.count) miembros")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            
            // 2. Categorías
            let foundCats = categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            if !foundCats.isEmpty {
                Section("Categorías") {
                    ForEach(foundCats) { cat in
                        HStack {
                            Image(systemName: cat.symbol)
                                .foregroundStyle(.blue)
                                .frame(width: 24)
                            Text(cat.name)
                                .font(.headline)
                        }
                    }
                }
            }
            
            // 3. Gastos
            let foundExpenses = expenses.filter {
                ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                ($0.note ?? "").localizedCaseInsensitiveContains(searchText)
            }
            
            if !foundExpenses.isEmpty {
                Section("Gastos") {
                    ForEach(foundExpenses) { expense in
                        NavigationLink(destination: EditExpenseView(expense: expense)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(expense.title ?? expense.category)
                                        .font(.body.weight(.medium))
                                    if let note = expense.note, !note.isEmpty {
                                        Text(note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(formatAmount(expense.amountInCents))
                                        .font(.callout.bold())
                                    Text(shortDate(expense.date))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            
            if foundGroups.isEmpty && foundCats.isEmpty && foundExpenses.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }
    
    private func formatAmount(_ cents: Int) -> String {
        let val = Double(cents) / 100.0
        return String(format: "$%.2f", val)
    }
    
    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        return f.string(from: date)
    }
}

