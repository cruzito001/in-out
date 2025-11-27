//
//  DashboardDistributionView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct DashboardDistributionView: View {
    @ObservedObject var vm: DashboardViewModel
    let expenses: [Expense]
    let allExpenses: [Expense]
    
    var body: some View {
        // 1. Donut Chart Section
        let breakdown = vm.categoriesBreakdown(expenses)
        let top5 = Array(breakdown.prefix(5))
        let totalAll = max(1, breakdown.map { $0.total }.reduce(0, +))
        
        HStack {
            Image(systemName: "chart.pie")
                .foregroundStyle(.blue)
            Text("Distribución por categorías")
                .font(.system(.title3, design: .rounded, weight: .bold))
            Spacer()
            Text("\(breakdown.count)")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .padding(.bottom, 8)
        
        if breakdown.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "chart.pie")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.blue)
                Text("No hay datos para el periodo/filtrado seleccionado")
                    .font(.system(.subheadline))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 32)
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        } else {
            VStack(spacing: 16) {
                DonutChart(
                    values: top5.map { Double($0.total) },
                    colors: top5.enumerated().map { vm.colorForIndex($0.offset) },
                    lineWidth: 22
                )
                .frame(height: 220)
                
                VStack(spacing: 10) {
                    ForEach(Array(top5.enumerated()), id: \.offset) { idx, item in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(vm.colorForIndex(idx))
                                .frame(width: 10, height: 10)
                            Text(item.name)
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .lineLimit(1)
                            Spacer()
                            HStack(spacing: 8) {
                                Text(vm.formatAmount(item.total, currencyCode: item.currency))
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .monospacedDigit()
                                Text(vm.formatPercent(Double(item.total) / Double(totalAll)))
                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.selectedCategoryName = item.name
                                vm.selected = .transacciones
                            }
                        }
                    }
                    
                    let more = Array(breakdown.dropFirst(top5.count))
                    if !more.isEmpty {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.showAllCategories.toggle()
                            }
                        } label: {
                            HStack {
                                Text(vm.showAllCategories ? "Ocultar otras" : "Mostrar todas")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                Spacer()
                                Image(systemName: vm.showAllCategories ? "chevron.up" : "chevron.down")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 6)
                        
                        if vm.showAllCategories {
                            Divider()
                                .opacity(0.15)
                                .padding(.vertical, 4)
                            
                            ForEach(Array(more.enumerated()), id: \.offset) { ridx, ritem in
                                VStack(spacing: 6) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(vm.colorForIndex(ridx + top5.count))
                                            .frame(width: 10, height: 10)
                                        Text(ritem.name)
                                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                                            .lineLimit(1)
                                        Spacer()
                                        HStack(spacing: 8) {
                                            Text(vm.formatAmount(ritem.total, currencyCode: ritem.currency))
                                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                                .monospacedDigit()
                                            Text(vm.formatPercent(Double(ritem.total) / Double(totalAll)))
                                                .font(.system(.caption, design: .rounded, weight: .medium))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    ProgressView(value: Double(ritem.total), total: Double(totalAll))
                                        .progressViewStyle(.linear)
                                        .tint(vm.colorForIndex(ridx + top5.count))
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        vm.selectedCategoryName = ritem.name
                                        vm.selected = .transacciones
                                    }
                                }
                            }
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
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
        }
        
        // 2. Bar Chart Section (Separated in UI by spacing)
        let currencyOptions = Array(vm.totalsByCurrency(allExpenses).keys).sorted()
        let buckets = vm.chartBuckets(allExpenses: allExpenses, range: vm.selectedChartRange, currency: vm.selectedChartCurrency)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                Text("Gasto total por periodo")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                Spacer()
                Text("\(buckets.count)")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            
            HStack(spacing: 8) {
                Menu {
                    ForEach(ChartRange.allCases) { r in
                        Button(action: { vm.selectedChartRange = r }) {
                            HStack {
                                Text(r.rawValue)
                                if vm.selectedChartRange == r { Spacer(); Image(systemName: "checkmark") }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                        Text(vm.selectedChartRange.rawValue)
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
                
                Menu {
                    ForEach(currencyOptions, id: \.self) { code in
                        Button(action: { vm.selectedChartCurrency = code }) {
                            HStack {
                                Image(systemName: vm.symbolForCurrency(code))
                                    Text(code)
                                if vm.selectedChartCurrency == code { Spacer(); Image(systemName: "checkmark") }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: vm.symbolForCurrency(vm.selectedChartCurrency))
                        Text("Moneda: \(vm.selectedChartCurrency)")
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            
            if buckets.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "tray")
                        .foregroundStyle(.secondary)
                    Text("No hay datos para el rango/moneda seleccionados")
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                BarChart(
                    values: buckets.map { Double($0.total) },
                    labels: buckets.map { $0.label },
                    color: .blue,
                    currencyCode: vm.selectedChartCurrency,
                    colors: buckets.enumerated().map { vm.colorForIndex($0.offset) }
                )
                .frame(height: 220)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
        .padding(.top, 12)
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
    }
}

