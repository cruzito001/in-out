//
//  GroupDetailView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI
import SwiftData

struct GroupDetailView: View {
    @Bindable var group: SplitGroup
    @Environment(\.modelContext) private var context
    
    enum DetailTab: String, CaseIterable {
        case expenses = "Gastos"
        case balances = "Balances"
    }
    
    @State private var selectedTab: DetailTab = .expenses
    @State private var showAddMember = false
    @State private var showAddExpense = false
    @State private var newMemberName = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Personalizado
            VStack(alignment: .leading, spacing: 12) {
                Text(group.name)
                    .font(.largeTitle.bold())
                
                // Lista de Miembros
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: { showAddMember = true }) {
                            VStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.title2)
                                    .frame(width: 50, height: 50)
                                    .background(.thinMaterial, in: Circle())
                                Text("Añadir")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        ForEach(group.members) { member in
                            VStack {
                                Text(String(member.name.prefix(1)))
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color(hex: member.colorHex) ?? .blue, in: Circle())
                                Text(member.name)
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteMember(member)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // Selector de Vistas
            Picker("Vista", selection: $selectedTab) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Contenido
            TabView(selection: $selectedTab) {
                expensesList
                    .tag(DetailTab.expenses)
                
                balancesView
                    .tag(DetailTab.balances)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Nuevo Participante", isPresented: $showAddMember) {
            TextField("Nombre", text: $newMemberName)
            Button("Cancelar", role: .cancel) { newMemberName = "" }
            Button("Añadir") {
                addMember()
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddGroupExpenseView(group: group)
                .presentationBackground(.thinMaterial)
        }
        .overlay(alignment: .bottomTrailing) {
            if selectedTab == .expenses {
                Button(action: { showAddExpense = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue, in: Circle())
                        .shadow(radius: 4, y: 2)
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var expensesList: some View {
        List {
            if group.expenses.isEmpty {
                ContentUnavailableView("Sin gastos", systemImage: "cart", description: Text("Añade el primer gasto del grupo"))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(group.expenses.sorted(by: { $0.date > $1.date })) { expense in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(expense.title)
                                .font(.headline)
                            if let payer = expense.paidBy {
                                Text("Pagó \(payer.name)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text(formatCurrency(expense.amount))
                            .font(.headline)
                            .monospacedDigit()
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            deleteExpense(expense)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    private var balancesView: some View {
        BalanceView(group: group)
    }
    
    // MARK: - Actions
    
    private func addMember() {
        guard !newMemberName.isEmpty else { return }
        let colors = ["007AFF", "FF9500", "AF52DE", "FF2D55", "5856D6", "34C759"]
        let color = colors.randomElement() ?? "007AFF"
        let member = SplitMember(name: newMemberName, colorHex: color)
        group.members.append(member)
        newMemberName = ""
    }
    
    private func deleteMember(_ member: SplitMember) {
        if let index = group.members.firstIndex(where: { $0.id == member.id }) {
            group.members.remove(at: index)
            context.delete(member)
        }
    }
    
    private func deleteExpense(_ expense: SplitExpense) {
        if let index = group.expenses.firstIndex(where: { $0.id == expense.id }) {
            group.expenses.remove(at: index)
            context.delete(expense)
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

