//
//  InsightCardView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI

struct InsightCardView: View {
    let insight: Insight
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Contenido Principal
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: insight.icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.white.opacity(0.25), in: Circle())
                    
                    Spacer()
                }
                
                Text(insight.title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(insight.message)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(width: 280, height: 170)
            .background(
                LinearGradient(
                    colors: gradientColors(for: insight.type),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: gradientColors(for: insight.type).first!.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Botón Compartir
            ShareLink(item: renderImage(), preview: SharePreview("Insight in-out", image: Image(systemName: "chart.bar.doc.horizontal"))) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.black.opacity(0.2), in: Circle())
            }
            .padding(12)
        }
    }
    
    private func gradientColors(for type: InsightType) -> [Color] {
        switch type {
        case .warning: return [Color.orange, Color.red]
        case .success: return [Color.green, Color.teal]
        case .info: return [Color.blue, Color.purple]
        }
    }
    
    // Renderizado de Imagen
    @MainActor
    private func renderImage() -> Image {
        let view = VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: insight.icon)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                Spacer()
                Text("in-out")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Text(insight.title)
                .font(.system(.title, design: .rounded, weight: .heavy))
                .foregroundStyle(.white)
            
            Text(insight.message)
                .font(.system(.title3, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.95))
        }
        .padding(30)
        .frame(width: 400, height: 400)
        .background(
            LinearGradient(
                colors: gradientColors(for: insight.type),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0 // Alta calidad
        
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
    }
}

