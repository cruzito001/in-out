//
//  SpendingDashboardView.swift
//  in-out
//
//  Created by Alan Cruz on 14/10/25.
//

import SwiftUI
import SwiftData

struct SpendingDashboardView: View {
    // MARK: - Selector (tipo Mail)
    enum Segment: String, CaseIterable, Identifiable {
        case resumen = "Resumen"
        case transacciones = "Transacciones"
        case distribucion = "Distribución"
        case tendencia = "Tendencia"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .resumen: return "person"
            case .transacciones: return "cart"
            case .distribucion: return "text.bubble"
            case .tendencia: return "speaker.wave.2"
            }
        }
    }
    
    // MARK: - Filtros secundarios
    enum Period: String, CaseIterable, Identifiable {
        case mesActual = "Mes actual"
        case mesAnterior = "Mes anterior"
        case tresMeses = "3 meses"
        case anio = "Año"
        case personalizado = "Personalizado"
        var id: String { rawValue }
    }
    
    @State private var selected: Segment = .resumen
    @State private var showAddSheet: Bool = false
    @State private var showAddCategorySheet: Bool = false
    @State private var selectedPeriod: Period = .mesActual
    @State private var selectedCategoryName: String = "Todas"
    @Query(sort: \Category.name) private var customCategories: [Category]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 14) {
                header
                selector
                filtersBar
                content
            }
            .padding(.horizontal, 20)
            .padding(.top, -180)
            .padding(.bottom, 40)
        }
        .fullScreenCover(isPresented: $showAddSheet) {
            AddExpenseView()
                .presentationBackground(.thinMaterial)
        }
        .fullScreenCover(isPresented: $showAddCategorySheet) {
            AddCategoryView()
                .presentationBackground(.thinMaterial)
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Control de gastos")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                Text("Actualizado justo ahora")
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Menu {
                Button(action: { showAddSheet = true }) {
                    Label("Agregar gasto", systemImage: "plus.circle")
                }
                Button(action: { showAddCategorySheet = true }) {
                    Label("Agregar categoría", systemImage: "folder.badge.plus")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(10)
                    .background(.thinMaterial, in: Circle())
            }
        }
    }
    
    // MARK: - Selector estilo Mail
    private var selector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(Segment.allCases) { segment in
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selected = segment } }) {
                        HStack(spacing: selected == segment ? 10 : 0) {
                            Image(systemName: segment.icon)
                                .font(.system(.headline, design: .rounded, weight: .semibold))
                                .foregroundStyle(selected == segment ? .white : .secondary)
                            if selected == segment {
                                Text(segment.rawValue)
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, selected == segment ? 18 : 16)
                        .padding(.vertical, 14)
                        .frame(minWidth: selected == segment ? 140 : 56)
                        .background(
                            Group {
                                if selected == segment {
                                    Capsule()
                                        .fill(
                                            LinearGradient(colors: [Color.blue, Color.blue.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                } else {
                                    Capsule()
                                        .fill(.thinMaterial)
                                }
                            }
                        )
                        .shadow(color: (selected == segment ? Color.blue : Color.black).opacity(selected == segment ? 0.3 : 0.08), radius: selected == segment ? 10 : 6, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 6)
        }
    }
    
    // MARK: - Filtros secundarios (placeholder)
    private var filtersBar: some View {
        HStack(spacing: 10) {
            Menu {
                ForEach(Period.allCases) { p in
                    Button(action: { selectedPeriod = p }) {
                        HStack {
                            Text(p.rawValue)
                            if selectedPeriod == p { Spacer(); Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                    Text("Periodo: \(selectedPeriod.rawValue)")
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            
            Menu {
                Button(action: { selectedCategoryName = "Todas" }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("Todas")
                        if selectedCategoryName == "Todas" { Spacer(); Image(systemName: "checkmark") }
                    }
                }
                ForEach(combinedCategories, id: \.name) { item in
                    Button(action: { selectedCategoryName = item.name }) {
                        HStack {
                            Image(systemName: item.symbol)
                            Text(item.name)
                            if selectedCategoryName == item.name { Spacer(); Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: (selectedCategoryName == "Todas" ? "slider.horizontal.3" : symbolForCategory(selectedCategoryName)))
                    Text("Categorías: \(selectedCategoryName)")
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            Spacer()
        }
    }
    
    // MARK: - Contenido (placeholder por segmento)
    private var content: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .frame(height: 220)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: iconForSelected())
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.blue)
                        Text(titleForSelected())
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("Aquí agregaremos gráficos y KPIs de \(selected.rawValue)")
                            .font(.system(.subheadline, design: .default))
                            .foregroundStyle(.secondary)
                    }
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func iconForSelected() -> String {
        switch selected {
        case .resumen: return "rectangle.grid.2x2.fill"
        case .transacciones: return "list.bullet"
        case .distribucion: return "chart.bar.fill"
        case .tendencia: return "chart.line.uptrend.xyaxis"
        }
    }
    
    private func titleForSelected() -> String {
        switch selected {
        case .resumen: return "Resumen del periodo"
        case .transacciones: return "Transacciones"
        case .distribucion: return "Distribución por categoría"
        case .tendencia: return "Tendencia"
        }
    }
    
}

#Preview {
    SpendingDashboardView()
}

private extension SpendingDashboardView {
    var combinedCategories: [CategoryItem] {
        var base = PredefinedCategories.all
        let customs = customCategories.map { CategoryItem(id: $0.id.uuidString, name: $0.name, symbol: $0.symbol) }
        let all = base + customs
        var seen = Set<String>()
        return all.filter { item in
            let key = item.name.lowercased()
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }

    func symbolForCategory(_ name: String) -> String {
        if let item = PredefinedCategories.all.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return item.symbol
        }
        if let custom = customCategories.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return custom.symbol
        }
        return "tag.fill"
    }
}
