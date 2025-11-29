//
//  SpendingDashboardView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI
import SwiftData

struct SpendingDashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    @Query(sort: \Category.name) private var customCategories: [Category]
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            contentList
                .safeAreaInset(edge: .top) {
                        DashboardHeaderView(vm: vm, expensesCount: allExpenses.count)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                }
        }
        .alert("Error", isPresented: $vm.showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.deleteErrorMessage)
        }
        .fullScreenCover(isPresented: $vm.showAddSheet) {
            AddExpenseView()
                .presentationBackground(.thinMaterial)
        }
        .fullScreenCover(isPresented: $vm.showAddCategorySheet) {
            AddCategoryView()
                .presentationBackground(.thinMaterial)
        }
        .sheet(isPresented: $vm.showSearch) {
            GlobalSearchView()
        }
        .fullScreenCover(item: $vm.expenseToEdit) { expense in
            EditExpenseView(expense: expense)
                .presentationBackground(.thinMaterial)
        }
        .alert("¿Eliminar gasto?", isPresented: $vm.showDeleteConfirm) {
            Button("Eliminar", role: .destructive) {
                if let e = vm.expensePendingDelete {
                    vm.deleteExpense(e, modelContext: modelContext)
                    vm.expensePendingDelete = nil
                }
            }
            Button("Cancelar", role: .cancel) {
                vm.expensePendingDelete = nil
            }
        } message: {
            if let e = vm.expensePendingDelete {
                Text("¿Quieres eliminar “\(e.title ?? e.category)”?")
            } else {
                Text("Eliminar gasto")
            }
        }
    }
    
    private var contentList: some View {
        List {
            // Selector y filtros
            Section {
                DashboardSelectorView(vm: vm)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .padding(.bottom, 10)
                
                DashboardFiltersView(vm: vm, customCategories: customCategories)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
            }

            // Contenido dinámico
            switch vm.selected {
            case .resumen:
                Section {
                    DashboardSummaryView(vm: vm, expenses: vm.filteredExpenses(allExpenses: allExpenses), customCategories: customCategories)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }
            case .transacciones:
                Section {
                    DashboardTransactionsView(vm: vm, expenses: vm.filteredExpenses(allExpenses: allExpenses), customCategories: customCategories)
                                        }
            case .distribucion:
                Section {
                    DashboardDistributionView(vm: vm, expenses: vm.filteredExpenses(allExpenses: allExpenses), allExpenses: allExpenses)
                            }
            case .tendencia:
                 Section {
                    DashboardTrendView(vm: vm, expenses: vm.filteredExpenses(allExpenses: allExpenses), allExpenses: allExpenses)
                 }
             }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .animation(.easeInOut(duration: 0.25), value: vm.selected)
    }
}

#Preview {
    SpendingDashboardView()
}
