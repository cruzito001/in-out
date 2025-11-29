//
//  RouletteCardsView.swift
//  in-out
//
//  Created by Alan Cruz
//

import SwiftUI
import SwiftData
import UIKit

struct RouletteCardsView: View {
    // MARK: - Models
    struct Participant: Identifiable, Equatable, Hashable {
        let id = UUID()
        var name: String
        var color: Color
    }
    
    // MARK: - State
    @State private var participants: [Participant] = []
    @State private var currentIndex: Int = 0
    @State private var isSpinning: Bool = false
    @State private var showWinner: Bool = false
    
    // Importación
    @Query(sort: \SplitGroup.date, order: .reverse) private var savedGroups: [SplitGroup]
    @State private var showGroupImportSheet = false
    @State private var showAddSheet = false
    @State private var newName = ""
    
    // Animación
    @State private var timer: Timer?
    @State private var speed: Double = 0.0
    
    // Diseño
    private let cardHeight: CGFloat = 120
    
    var body: some View {
        ZStack {
            // Fondo Dinámico
            animatedBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Flotante
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Spacer()
                
                // Área de Ruleta
                if participants.isEmpty {
                    emptyState
                } else {
                    rouletteWheel
                }
                
                Spacer()
                
                // Controles
                controls
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
            
            if showWinner {
                winnerOverlay
            }
        }
        .sheet(isPresented: $showGroupImportSheet) {
            groupImportView
                .presentationDetents([.medium, .large])
                .presentationBackground(.thinMaterial)
        }
        .alert("Nuevo Participante", isPresented: $showAddSheet) {
            TextField("Nombre", text: $newName)
            Button("Cancelar", role: .cancel) { newName = "" }
            Button("Añadir") { addParticipant() }
        }
    }
    
    // MARK: - Components
    
    private var animatedBackground: some View {
        let currentColor = participants.isEmpty ? Color.gray : participants[currentIndex % participants.count].color
        
        return ZStack {
            Color.black
            
            // Mesh Gradient Simulado (Círculos borrosos)
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(currentColor.opacity(0.4))
                        .frame(width: geo.size.width * 1.5)
                        .blur(radius: 100)
                        .offset(x: -geo.size.width * 0.3, y: -geo.size.height * 0.3)
                    
                    Circle()
                        .fill(currentColor.opacity(0.3))
                        .frame(width: geo.size.width * 1.2)
                        .blur(radius: 80)
                        .offset(x: geo.size.width * 0.4, y: geo.size.height * 0.4)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: currentIndex)
    }
    
    private var header: some View {
        HStack {
            Text("Ruleta")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Spacer()
            
            Menu {
                Button(action: { showAddSheet = true }) {
                    Label("Añadir manual", systemImage: "person.badge.plus")
                }
                Button(action: { showGroupImportSheet = true }) {
                    Label("Importar de Grupo", systemImage: "person.3.fill")
                }
                if !participants.isEmpty {
                    Divider()
                    Button(role: .destructive, action: { participants.removeAll() }) {
                        Label("Limpiar todo", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.white.opacity(0.2), in: Circle())
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.5))
            
            Text("Añade participantes")
                .font(.title3.bold())
                .foregroundStyle(.white.opacity(0.8))
            
            Button(action: { showGroupImportSheet = true }) {
                Text("Importar Grupo")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white, in: Capsule())
                    .foregroundStyle(.black)
            }
        }
    }
    
    private var rouletteWheel: some View {
        let count = participants.count
        let current = participants[currentIndex % count]
        let prevIndex = (currentIndex - 1 + count) % count
        let nextIndex = (currentIndex + 1) % count
        
        return ZStack {
            // Indicador de selección (Simplificado)
            HStack {
                Image(systemName: "arrowtriangle.right.fill")
                Spacer()
                Image(systemName: "arrowtriangle.left.fill")
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                // Anterior (Desvanecido)
                if count > 1 {
                    Text(participants[prevIndex].name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                        .frame(height: cardHeight)
                        .scaleEffect(0.8)
                        .blur(radius: 2)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                
                // ACTUAL
                Text(current.name)
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(height: cardHeight)
                    .scaleEffect(1.1)
                    .shadow(color: current.color.opacity(0.8), radius: 30, x: 0, y: 0)
                    .minimumScaleFactor(0.4) // Permite reducir tamaño si es largo
                    .lineLimit(1)
                    .padding(.horizontal, 40) // Espacio para las flechas
                    .id("center-\(currentIndex)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                
                // Siguiente (Desvanecido)
                if count > 1 {
                    Text(participants[nextIndex].name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                        .frame(height: cardHeight)
                        .scaleEffect(0.8)
                        .blur(radius: 2)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
            }
            .clipped() // Solo clippeamos verticalmente lo necesario
        }
        .frame(height: cardHeight * 3)
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.2),
                    .init(color: .black, location: 0.8),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var controls: some View {
        Button(action: spin) {
            Text(isSpinning ? "Girando..." : "GIRAR")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
                .shadow(color: .white.opacity(0.3), radius: 15)
                .scaleEffect(isSpinning ? 0.95 : 1.0)
                .animation(.spring, value: isSpinning)
        }
        .disabled(isSpinning || participants.count < 2)
        .opacity(participants.count < 2 ? 0.5 : 1)
    }
    
    private var winnerOverlay: some View {
        ZStack {
            // Fondo Blur
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // Partículas o Glow extra (Opcional, simple por ahora)
            
            VStack(spacing: 40) {
                Text("🎉 El elegido es")
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(0.9))
                
                let winner = participants[currentIndex % participants.count]
                
                Text(winner.name)
                    .font(.system(size: 70, weight: .black, design: .rounded))
                    .foregroundStyle(winner.color) // Color del ganador
                    .multilineTextAlignment(.center)
                    .shadow(color: winner.color.opacity(0.8), radius: 40)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal)
                    .scaleEffect(1.2) // Zoom in
                
                Button("Continuar") {
                    withAnimation { showWinner = false }
                }
                .font(.headline)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(Color.white, in: Capsule())
                .foregroundStyle(.black)
                .shadow(radius: 10)
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 1.1)))
        .zIndex(100)
    }
    
    // MARK: - Logic
    
    private func spin() {
        isSpinning = true
        speed = 0.02 // Velocidad inicial (segundos por tick)
        var ticks = 0
        let maxTicks = Int.random(in: 30...50) // Duración aleatoria
        
        // Timer recursivo para desaceleración variable
        func runTick() {
            // Detener
            if ticks >= maxTicks {
                finishSpin()
                return
            }
            
            // Avanzar índice
            withAnimation(.linear(duration: speed)) {
                currentIndex += 1
            }
            
            // Haptic Feedback
            let style: UIImpactFeedbackGenerator.FeedbackStyle = ticks < maxTicks - 10 ? .light : .medium
            UIImpactFeedbackGenerator(style: style).impactOccurred()
            
            // Calcular nueva velocidad (Desaceleración exponencial)
            if ticks > maxTicks - 15 {
                speed *= 1.15 // Frenar drásticamente al final
            } else if ticks < 10 {
                speed *= 0.9 // Acelerar al principio
            }
            
            ticks += 1
            
            // Programar siguiente tick
            DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
                runTick()
            }
        }
        
        runTick()
    }
    
    private func finishSpin() {
        isSpinning = false
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showWinner = true
            }
        }
    }
    
    private func addParticipant() {
        guard !newName.isEmpty else { return }
        let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .cyan, .yellow]
        participants.append(Participant(name: newName, color: colors.randomElement() ?? .white))
        newName = ""
    }
    
    // MARK: - Import Sheet
    private var groupImportView: some View {
        NavigationView {
            List(savedGroups) { group in
                Button {
                    importGroup(group)
                } label: {
                    HStack {
                        Text(group.name)
                            .font(.headline)
                        Spacer()
                        Text("\(group.members.count) miembros")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Seleccionar Grupo")
            .overlay {
                if savedGroups.isEmpty {
                    ContentUnavailableView("No hay grupos", systemImage: "person.3", description: Text("Crea grupos en la pestaña División para importarlos aquí."))
                }
            }
        }
    }
    
    private func importGroup(_ group: SplitGroup) {
        let newParticipants = group.members.map { member in
            Participant(
                name: member.name,
                color: Color(hex: member.colorHex) ?? .blue
            )
        }
        participants.append(contentsOf: newParticipants)
        showGroupImportSheet = false
    }
}

#Preview {
    RouletteCardsView()
}
