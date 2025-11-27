//
//  ChartComponents.swift
//  in-out
//
//

import SwiftUI

struct DonutChart: View {
    let values: [Double]
    let colors: [Color]
    var lineWidth: CGFloat = 22

    var body: some View {
        let total = max(1.0, values.reduce(0, +))
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: lineWidth)
            ForEach(Array(values.enumerated()), id: \.offset) { idx, v in
                let start = values.prefix(idx).reduce(0, +) / total
                let end = start + v / total
                Circle()
                    .trim(from: CGFloat(start), to: CGFloat(end))
                    .stroke(colors[idx % colors.count], style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct BarChart: View {
    let values: [Double]
    let labels: [String]
    let color: Color
    var maxValue: Double? = nil
    var currencyCode: String? = nil
    var colors: [Color]? = nil
    @State private var selectedIndex: Int? = nil

    var body: some View {
        GeometryReader { geo in
            let maxVal = maxValue ?? max(values.max() ?? 1, 1)
            let barCount = max(labels.count, 1)
            let spacing: CGFloat = 8
            let barWidth = max(1, (geo.size.width - spacing * CGFloat(barCount - 1)) / CGFloat(barCount))
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(Array(values.enumerated()), id: \.offset) { idx, v in
                        let h = CGFloat(v / maxVal) * max(geo.size.height - 28, 1)
                        let barColor = (colors?[idx] ?? color)
                        VStack(spacing: 6) {
                            if selectedIndex == idx, let code = currencyCode {
                                Text(formatValue(v, code: code))
                                    .font(.system(.caption, design: .rounded, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial, in: Capsule())
                                    .monospacedDigit()
                            }
                            Rectangle()
                                .fill(barColor.opacity(v == 0 ? 0.25 : 1))
                                .frame(width: barWidth, height: h)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture { selectedIndex = (selectedIndex == idx ? nil : idx) }
                            Text(labels[idx])
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.secondary)
                                .frame(width: barWidth)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    private func formatValue(_ cents: Double, code: String) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = code
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        return nf.string(from: NSNumber(value: cents / 100.0)) ?? String(format: "%.2f", cents / 100.0)
    }
}

