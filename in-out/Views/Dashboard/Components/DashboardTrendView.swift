//
//  DashboardTrendView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct DashboardTrendView: View {
    @ObservedObject var vm: DashboardViewModel
    let expenses: [Expense]
    
    var body: some View {
        let trendData = vm.trendData(expenses: expenses)
        let avgDaily = vm.averageDailySpend(expenses: expenses)
        let projected = vm.projectedEndOfMonth(expenses: expenses, period: vm.selectedPeriod)
        
        VStack(spacing: 16) {
            // 1. Gráfico de Tendencia
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.xyaxis.line")
                        .foregroundStyle(.blue)
                    Text("Tendencia de gasto diario")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Spacer()
                }
                
                if trendData.values.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text("No hay suficientes datos para mostrar la tendencia")
                            .font(.system(.subheadline))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .padding(.vertical, 20)
                } else {
                    LineChart(
                        data: trendData.values,
                        labels: trendData.labels,
                        color: .blue,
                        currencyCode: vm.selectedChartCurrency
                    )
                    .frame(height: 220) // Increased height for axis labels
                    .padding(.top, 8)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
            )
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            
            // 2. KPIs
            HStack(spacing: 12) {
                // KPI 1: Promedio Diario
                VStack(alignment: .leading, spacing: 8) {
                    Text("Promedio diario")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text(formatValue(avgDaily))
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.thinMaterial)
                )
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // KPI 2: Proyección (Solo Mes Actual)
                if vm.selectedPeriod == .mesActual {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Proyección fin de mes")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        Text(formatValue(projected))
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.thinMaterial)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
    }
    
    private func formatValue(_ val: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "MXN" // Idealmente usar moneda principal detectada
        return nf.string(from: NSNumber(value: val)) ?? String(format: "$%.2f", val)
    }
}
