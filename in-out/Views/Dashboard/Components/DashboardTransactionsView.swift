//
//  DashboardTransactionsView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct DashboardTransactionsView: View {
    @ObservedObject var vm: DashboardViewModel
    let expenses: [Expense]
    let customCategories: [Category]

    var body: some View {
        // Encabezado "Transacciones"
        HStack {
            Image(systemName: "list.bullet")
                .foregroundStyle(.blue)
            Text("Transacciones")
                .font(.system(.title3, design: .rounded, weight: .bold))
            Spacer()
            Text("\(expenses.count)")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .padding(.bottom, 8)

        if expenses.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.blue)
                Text("Aún no hay gastos en el periodo seleccionado")
                    .font(.system(.subheadline))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 32)
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        } else {
            ForEach(expenses, id: \.id) { e in
                HStack(spacing: 12) {
                    Image(systemName: vm.symbolForCategory(e.category, customCategories: customCategories))
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(e.title ?? e.category)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .lineLimit(1)
                        Text(vm.shortDate(e.date))
                            .font(.system(.caption, design: .default))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(vm.formatAmount(e.amountInCents, currencyCode: e.currencyCode))
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .monospacedDigit()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                )
                .contentShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                .padding(.vertical, 6)
                .contextMenu {
                    Button(role: .destructive) { vm.askDelete(e) } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) { vm.askDelete(e) } label: {
                        Image(systemName: "trash")
                    }
                    Button { vm.startEditing(e) } label: {
                        Image(systemName: "pencil")
                    }
                    .tint(.blue)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
            }
        }
    }
}

