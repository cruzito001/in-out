//
//  RouletteCardsView.swift
//  in-out
//
//

import SwiftUI
import UIKit

struct RouletteCardsView: View {
    // MARK: - Model
    struct Participant: Identifiable, Equatable {
        let id = UUID()
        var name: String
        var color: Color
    }
    
    // MARK: - State
    @State private var participants: [Participant] = []
    @State private var selectedIndex: Int = 0
    @State private var isSpinning: Bool = false
    @State private var lastWinnerIndex: Int? = nil
    @State private var showAddSheet: Bool = false
    @State private var newName: String = ""
    @State private var newColor: Color = .blue
    @State private var avoidImmediateRepeat: Bool = true
    @State private var showWinnerBanner: Bool = false
    @State private var winnerPulse: Bool = false
    
    // MARK: - Constants
    private let palette: [Color] = [.blue, .indigo, .purple, .pink, .teal, .green, .orange]
    
    var body: some View {
        ZStack {
            // Background
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
            
            VStack(spacing: 20) {
                header
                
                if participants.isEmpty {
                    emptyState
                } else {
                    carousel
                }
                
                controls
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            if showWinnerBanner, let winner = currentWinner {
                winnerBanner(winner)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showAddSheet) {
            addParticipantSheet
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            Text("¿Quién paga?")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            Text("Agrega participantes y sortea")
                .font(.system(.subheadline, design: .default, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(.blue)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            Text("Aún no hay participantes")
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
            Text("Añade al menos dos personas para empezar el sorteo")
                .font(.system(.body, design: .default))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(action: { showAddSheet = true }) {
                Text("Añadir participante")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .background(
                LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .padding(24)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 4)
    }
    
    // MARK: - Carousel
    private var carousel: some View {
        VStack(spacing: 18) {
            TabView(selection: $selectedIndex) {
                ForEach(Array(participants.enumerated()), id: \.element.id) { index, participant in
                    ParticipantCard(participant: participant, isFocused: index == selectedIndex)
                        .padding(.horizontal, 10)
                        .tag(index)
                        .contextMenu {
                            Button(role: .destructive) { removeParticipant(at: index) } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 280)
            .animation(.easeInOut(duration: 0.25), value: selectedIndex)
            
            // participantes
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(participants.enumerated()), id: \.element.id) { index, p in
                        Button(action: { withAnimation { selectedIndex = index } }) {
                            HStack(spacing: 6) {
                                Circle().fill(p.color).frame(width: 8, height: 8)
                                Text(p.name)
                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                    .foregroundStyle(index == selectedIndex ? .blue : .primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                .thinMaterial,
                                in: Capsule()
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal, 6)
            }
        }
    }
    
    // MARK: - Controls
    private var controls: some View {
        VStack(spacing: 14) {
            Button(action: spin) {
                Text(isSpinning ? "Sorteando..." : "Barajar y sortear")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .background(
                LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
            .disabled(participants.count < 2 || isSpinning)
            
            HStack(spacing: 12) {
                Button(action: { showAddSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Añadir participante")
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: 14)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                
                Menu {
                    Toggle("Evitar repetición inmediata", isOn: $avoidImmediateRepeat)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Opciones")
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: 160)
                    .padding(.vertical, 14)
                }
                .background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: 14)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Winner Banner
    private func winnerBanner(_ winner: Participant) -> some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .transition(.opacity)
            
            ZStack {
                Circle()
                    .stroke(winner.color.opacity(0.5), lineWidth: 6)
                    .frame(width: 220, height: 220)
                    .scaleEffect(winnerPulse ? 1.12 : 0.88)
                    .opacity(winnerPulse ? 0.0 : 0.6)
                    .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: winnerPulse)
                
                Circle()
                    .stroke(Color.white.opacity(0.35), lineWidth: 3)
                    .frame(width: 180, height: 180)
                    .scaleEffect(winnerPulse ? 1.0 : 0.85)
                    .opacity(winnerPulse ? 0.0 : 0.8)
                    .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: winnerPulse)
                
                // winner card
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.yellow)
                    Text("Gana")
                        .font(.system(.headline, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(winner.name)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 22)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.65), Color.white.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 8)
                .transition(.scale.combined(with: .opacity))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { winnerPulse = true }
        .onDisappear { winnerPulse = false }
    }
    
    // MARK: - Add Participant Sheet
    private var addParticipantSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Nuevo Participante")) {
                    TextField("Nombre", text: $newName)
                    ColorPicker("Color de la tarjeta", selection: $newColor, supportsOpacity: false)
                }
            }
            .navigationTitle("Añadir")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { showAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { addParticipant() }
                        .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private var currentWinner: Participant? {
        guard let idx = lastWinnerIndex, participants.indices.contains(idx) else { return nil }
        return participants[idx]
    }
    
    private func addParticipant() {
        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let p = Participant(name: name, color: newColor)
        participants.append(p)
        newName = ""
        newColor = palette.randomElement() ?? .blue
        showAddSheet = false
        if participants.count == 1 { selectedIndex = 0 }
    }
    
    private func removeParticipant(at index: Int) {
        guard participants.indices.contains(index) else { return }
        participants.remove(at: index)
        if participants.isEmpty {
            selectedIndex = 0
            lastWinnerIndex = nil
            showWinnerBanner = false
        } else {
            selectedIndex = min(selectedIndex, participants.count - 1)
        }
    }
    
    private func spin() {
        guard participants.count >= 2, !isSpinning else { return }
        isSpinning = true
        showWinnerBanner = false
        
        // Decider ganador
        var winner = Int.random(in: 0..<participants.count)
        if avoidImmediateRepeat, participants.count > 1, let last = lastWinnerIndex, winner == last {
            var options = Array(0..<participants.count)
            options.removeAll { $0 == last }
            if let alt = options.randomElement() { winner = alt }
        }
        
        // Animación de giro con desaceleración
        let totalSteps = 18 + Int.random(in: 6...12) // vueltas visuales
        var step = 0
        var delay: Double = 0.06
        
        func performStep() {
            guard step < totalSteps else {
                withAnimation(.easeOut(duration: 0.45)) {
                    selectedIndex = winner
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    announceWinner(index: winner)
                }
                return
            }
            withAnimation(.easeInOut(duration: delay)) {
                selectedIndex = (selectedIndex + 1) % participants.count
            }
            step += 1
            delay = min(delay * 1.08, 0.18) // desacelera ligeramente
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                performStep()
            }
        }
        
        // Haptic
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        performStep()
    }
    
    private func announceWinner(index: Int) {
        lastWinnerIndex = index
        // Haptic de éxito
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showWinnerBanner = true
        }
        // Ocultar banner tras unos segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.5)) {
                showWinnerBanner = false
            }
            isSpinning = false
        }
    }
}

// MARK: - Card
private struct ParticipantCard: View {
    let participant: RouletteCardsView.Participant
    let isFocused: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [participant.color.opacity(0.9), participant.color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.white.opacity(0.02)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)
                )
                .shadow(color: .black.opacity(isFocused ? 0.15 : 0.08), radius: isFocused ? 14 : 8, x: 0, y: 6)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.system(.title2, design: .default, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                }
                
                Spacer()
                
                Text(participant.name)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                Text("Tarjeta de participante")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(22)
        }
        .frame(height: 240)
        .scaleEffect(isFocused ? 1.0 : 0.93)
        .rotation3DEffect(
            .degrees(isFocused ? 0 : 8),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.25), value: isFocused)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Participante: \(participant.name)"))
    }
}

#Preview {
    RouletteCardsView()
}