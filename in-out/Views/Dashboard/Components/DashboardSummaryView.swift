//
//  DashboardSummaryView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct DashboardSummaryView: View {
    @ObservedObject var vm: DashboardViewModel
    let expenses: [Expense]
    let customCategories: [Category]

    var body: some View {
        let totals = vm.totalsByCurrency(expenses)
        let top = vm.topCategory(expenses)
        let latest = Array(expenses.sorted(by: { $0.date > $1.date }).prefix(3))

        return VStack(spacing: 16) {
            // Card 1: Resumen (totales por moneda)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(.blue)
                    Text("Resumen")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Spacer()
                    Text("\(expenses.count) gastos")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                }

                if !totals.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(totals.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            HStack(spacing: 6) {
                                Image(systemName: vm.symbolForCurrency(key))
                                    .foregroundStyle(.secondary)
                                Text(vm.formatAmount(value, currencyCode: key))
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .monospacedDigit()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.thinMaterial, in: Capsule())
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
            )
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            .frame(maxWidth: .infinity)

            // Card 2: Categoría principal
            if let top {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: vm.symbolForCategory(top.name, customCategories: customCategories))
                            .foregroundStyle(.secondary)
                        Text("Categoría principal")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                        Spacer()
                    }
                    HStack(spacing: 8) {
                        Text(top.name)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .lineLimit(1)
                        Spacer()
                        Text(vm.formatAmount(top.total, currencyCode: top.currency))
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .monospacedDigit()
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                .frame(maxWidth: .infinity)
            }

            // Card 3: Últimos movimientos (3) + "Ver todos"
            if !latest.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.blue)
                        Text("Últimos movimientos")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                        Spacer()
                        Text("\(latest.count)")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: Capsule())
                        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { vm.selected = .transacciones } }) {
                            HStack(spacing: 4) {
                                Text("Ver todos")
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .buttonStyle(.plain)
                    }

                    VStack(spacing: 8) {
                        ForEach(latest, id: \.id) { e in
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
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.ultraThinMaterial)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

