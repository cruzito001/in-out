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
                        .foregroundStyle(insight.color) // Color solo en icono
                        .padding(10)
                        .background(insight.color.opacity(0.15), in: Circle()) // Fondo sutil
                    
                    Spacer()
                }
                
                Text(insight.title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(insight.message)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(width: 280, height: 160)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground)) // Fondo nativo oscuro
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(insight.color.opacity(0.3), lineWidth: 1) // Borde sutil de color
            )
            
            // Botón Compartir
            ShareLink(item: renderImage(), preview: SharePreview("Insight in-out", image: Image(systemName: "chart.bar.doc.horizontal"))) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(12)
        }
    }
    
    // Renderizado de Imagen para compartir (Estilo Dark Mode)
    @MainActor
    private func renderImage() -> Image {
        let view = VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: insight.icon)
                    .font(.largeTitle)
                    .foregroundStyle(insight.color)
                    .padding(16)
                    .background(insight.color.opacity(0.15), in: Circle())
                
                Spacer()
                
                Text("in-out")
                    .font(.caption.bold())
                    .foregroundStyle(.gray)
            }
            
            Text(insight.title)
                .font(.system(.title, design: .rounded, weight: .heavy))
                .foregroundStyle(.white) // Forzar blanco para imagen
            
            Text(insight.message)
                .font(.system(.title3, design: .rounded, weight: .medium))
                .foregroundStyle(.gray)
        }
        .padding(40)
        .frame(width: 400, height: 400)
        .background(Color(hex: "1C1C1E")) // Gris oscuro fijo para la imagen
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(insight.color, lineWidth: 4) // Borde de color más grueso en imagen
        )
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
    }
}

