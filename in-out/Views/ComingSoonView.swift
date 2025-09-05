//
//  ComingSoonView.swift
//  in-out
//
//  Created by Alan Joel Cruz Ortega on 04/09/25.
//

import SwiftUI

struct ComingSoonView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGroupedBackground),
                    Color(.secondarySystemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo de la app
                Image("logoApp")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Contenedor principal con el mismo estilo
                VStack(spacing: 24) {
                    // Icono principal
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundStyle(.blue)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // Título principal
                    Text("Próximamente")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Subtítulo
                    Text("Esta función estará disponible muy pronto")
                        .font(.system(.title2, design: .default, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Mensaje adicional
                    Text("Estamos trabajando para traerte nuevas funcionalidades que mejorarán tu experiencia financiera")
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    
                    // Indicador de progreso decorativo
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(.blue.opacity(0.6))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == 1 ? 1.2 : 1.0)
                                .animation(
                                    .easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: index
                                )
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 40)
                .background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

#Preview {
    ComingSoonView()
}
