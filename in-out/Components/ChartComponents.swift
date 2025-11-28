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
            // Calculate bar width strictly
            let totalSpacing = spacing * CGFloat(barCount - 1)
            let barWidth = max(1, (geo.size.width - totalSpacing) / CGFloat(barCount))
            
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .bottomLeading) {
                    // Bars Layer
                    HStack(alignment: .bottom, spacing: spacing) {
                        ForEach(Array(values.enumerated()), id: \.offset) { idx, v in
                            let h = CGFloat(v / maxVal) * max(geo.size.height - 28, 1)
                            let barColor = (colors?[idx] ?? color)
                            
                            VStack(spacing: 6) {
                                // Invisible spacer to reserve height for tooltip if needed, 
                                // or just keep bar layout clean. We move tooltip to overlay.
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
                    
                    // Tooltip Overlay
                    if let idx = selectedIndex, let code = currencyCode, idx < values.count {
                        let v = values[idx]
                        let h = CGFloat(v / maxVal) * max(geo.size.height - 28, 1)
                        // Calculate X position: (barWidth + spacing) * idx + barWidth/2
                        let xPos = (barWidth + spacing) * CGFloat(idx) + barWidth / 2
                        // Y position: Height of container - Axis Labels (approx 20) - Bar Height - padding
                        let yPos = geo.size.height - 28 - h - 10
                        
                        // Smart horizontal offset to prevent clipping
                        let isFarRight = idx > (barCount - 2)
                        let isFarLeft = idx < 1
                        let xOffset: CGFloat = isFarRight ? -20 : (isFarLeft ? 20 : 0)

                        Text(formatValue(v, code: code))
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                            .shadow(radius: 4)
                            .position(x: xPos + xOffset, y: max(yPos, 20)) // Ensure it doesn't go off top
                            .allowsHitTesting(false) // Pass taps through
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(10) // Ensure it's on top
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

struct LineChart: View {
    let data: [Double]
    let labels: [String]
    let color: Color
    var currencyCode: String = "MXN"
    
    @State private var selectedIndex: Int? = nil
    @State private var dragLocation: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let maxVal = (data.max() ?? 1) * 1.1 // Add some headroom
            let minVal = 0.0 // Base at 0 for better context
            let range = max(maxVal - minVal, 1)
            
            ZStack(alignment: .topLeading) {
                // Grid Lines (Horizontal)
                VStack {
                    ForEach(0..<4) { i in
                        let val = maxVal - (Double(i) * maxVal / 3.0)
                        HStack {
                            Text(formatValue(val, code: currencyCode))
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .frame(width: 40, alignment: .trailing)
                            Rectangle()
                                .fill(Color.secondary.opacity(0.1))
                                .frame(height: 1)
                        }
                        if i < 3 { Spacer() }
                    }
                }
                .padding(.trailing, 8)
                
                // Chart Content
                if data.count > 1 {
                    let chartWidth = width - 50 // Reserve space for Y axis labels
                    let xStep = chartWidth / CGFloat(data.count - 1)
                    
                    ZStack {
                        // Gradient Fill
                        Path { path in
                            path.move(to: CGPoint(x: 50, y: height))
                            for (index, value) in data.enumerated() {
                                let x = 50 + CGFloat(index) * xStep
                                let y = height - (height * CGFloat(value - minVal) / CGFloat(range))
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                            path.addLine(to: CGPoint(x: 50 + chartWidth, y: height))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Line Stroke
                        Path { path in
                            for (index, value) in data.enumerated() {
                                let x = 50 + CGFloat(index) * xStep
                                let y = height - (height * CGFloat(value - minVal) / CGFloat(range))
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        
                        // Interaction Overlay
                        if let sel = selectedIndex, sel < data.count {
                            let x = 50 + CGFloat(sel) * xStep
                            let y = height - (height * CGFloat(data[sel] - minVal) / CGFloat(range))
                            
                            // Vertical Line
                            Rectangle()
                                .fill(Color.primary.opacity(0.2))
                                .frame(width: 1, height: height)
                                .position(x: x, y: height / 2)
                            
                            // Point
                            Circle()
                                .fill(color)
                                .frame(width: 12, height: 12)
                                .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                                .position(x: x, y: y)
                                .shadow(radius: 3)
                            
                            // Tooltip
                            VStack(spacing: 2) {
                                Text(formatValue(data[sel], code: currencyCode))
                                    .font(.system(.caption, design: .rounded, weight: .bold))
                                    .foregroundStyle(.primary)
                                Text(labels[sel])
                                    .font(.system(.caption2, design: .default))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .shadow(radius: 5)
                            .position(x: min(max(x, 60), width - 60), y: max(y - 40, 30))
                        }
                    }
                    .contentShape(Rectangle()) // Make the whole chart interactive
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - 50
                                let step = chartWidth / CGFloat(data.count - 1)
                                let index = Int(round(x / step))
                                selectedIndex = min(max(0, index), data.count - 1)
                            }
                            .onEnded { _ in
                                // Optional: selectedIndex = nil // Keep selected or dismiss on lift? Let's keep it for better UX
                            }
                    )
                    .onTapGesture {
                        // Clear selection on tap outside valid area or toggle
                        if selectedIndex != nil { selectedIndex = nil }
                    }
                }
            }
        }
    }
    
    private func formatValue(_ val: Double, code: String) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = code
        nf.maximumFractionDigits = 0 // No cents for axis labels to save space
        if val < 1000 {
            nf.maximumFractionDigits = 2
        }
        return nf.string(from: NSNumber(value: val)) ?? String(format: "%.0f", val)
    }
}
