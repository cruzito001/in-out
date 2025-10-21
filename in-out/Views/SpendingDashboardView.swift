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

    enum ChartRange: String, CaseIterable, Identifiable {
        case last3Months = "Últimos 3 meses"
        case lastMonthByWeek = "Mes actual por semana"
        case lastYear = "Último año"
        case last3Years = "Últimos 3 años"
        var id: String { rawValue }
    }
    
    @State private var selected: Segment = .resumen
    @State private var showAddSheet: Bool = false
    @State private var showAddCategorySheet: Bool = false
    @State private var selectedPeriod: Period = .mesActual
    @State private var selectedCategoryName: String = "Todas"
    @State private var showAllCategories: Bool = false
    @State private var selectedChartRange: ChartRange = .last3Months
    @State private var selectedChartCurrency: String = "MXN"
    @Query(sort: \Category.name) private var customCategories: [Category]
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteError: Bool = false
    @State private var deleteErrorMessage: String = ""
    @State private var expenseToEdit: Expense?
    @State private var showDeleteConfirm: Bool = false
    @State private var expensePendingDelete: Expense?
    
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
            
            transactionsList
                .safeAreaInset(edge: .top) {
                    header
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                }
        }
        .alert("Error", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteErrorMessage)
        }
        .fullScreenCover(isPresented: $showAddSheet) {
            AddExpenseView()
                .presentationBackground(.thinMaterial)
        }
        .fullScreenCover(isPresented: $showAddCategorySheet) {
            AddCategoryView()
                .presentationBackground(.thinMaterial)
        }
        .fullScreenCover(item: $expenseToEdit) { expense in
            EditExpenseView(expense: expense)
                .presentationBackground(.thinMaterial)
        }
        .alert("¿Eliminar gasto?", isPresented: $showDeleteConfirm) {
            Button("Eliminar", role: .destructive) {
                if let e = expensePendingDelete {
                    deleteExpense(e)
                    expensePendingDelete = nil
                }
            }
            Button("Cancelar", role: .cancel) {
                expensePendingDelete = nil
            }
        } message: {
            if let e = expensePendingDelete {
                Text("¿Quieres eliminar “\(e.title ?? e.category)”?")
            } else {
                Text("Eliminar gasto")
            }
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
                Text("Actualizado justo ahora • \(allExpenses.count == 1 ? "1 gasto" : "\(allExpenses.count) gastos")")
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
        .padding(.bottom, 16)
    }
    
    // MARK: - Contenido (por segmento)
    private var content: some View {
        VStack(spacing: 16) {
            if selected == .resumen {
                summaryView
            } else if selected == .transacciones {
                transactionsList
                    .padding(.top, 20)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: selected.icon)
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(.blue)
                            Text(selected.rawValue)
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundStyle(.primary)
                            Text("Aquí agregaremos gráficos y KPIs de \(selected.rawValue)")
                                .font(.system(.subheadline, design: .default))
                                .foregroundStyle(.secondary)
                        }
                    )
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Resumen
    private var summaryView: some View {
        let expenses = filteredExpenses()
        let totals = totalsByCurrency(expenses)
        let top = topCategory(expenses)
        let latest = Array(expenses.sorted(by: { $0.date > $1.date }).prefix(3))

        return VStack(spacing: 16) {
            // Card 1: Resumen (totales por moneda)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(.blue)
                    Text("Resumen")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Spacer()
                    Text("\(expenses.count) gastos")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                }

                if !totals.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(totals.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            HStack(spacing: 6) {
                                Image(systemName: symbolForCurrency(key))
                                    .foregroundStyle(.secondary)
                                Text(formatAmount(value, currencyCode: key))
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .monospacedDigit()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.thinMaterial, in: Capsule())
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

            // Card 2: Categoría principal
            if let top {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: symbolForCategory(top.name))
                            .foregroundStyle(.secondary)
                        Text("Categoría principal")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                        Spacer()
                    }
                    HStack(spacing: 8) {
                        Text(top.name)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .lineLimit(1)
                        Spacer()
                        Text(formatAmount(top.total, currencyCode: top.currency))
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .monospacedDigit()
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                .frame(maxWidth: .infinity)
            }

            // Card 3: Últimos movimientos (3) + "Ver todos"
            if !latest.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.blue)
                        Text("Últimos movimientos")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                        Spacer()
                        Text("\(latest.count)")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: Capsule())
                        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selected = .transacciones } }) {
                            HStack(spacing: 4) {
                                Text("Ver todos")
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .buttonStyle(.plain)
                    }

                    VStack(spacing: 8) {
                        ForEach(latest, id: \.id) { e in
                            HStack(spacing: 12) {
                                Image(systemName: symbolForCategory(e.category))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(e.title ?? e.category)
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        .lineLimit(1)
                                    Text(shortDate(e.date))
                                        .font(.system(.caption, design: .default))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(formatAmount(e.amountInCents, currencyCode: e.currencyCode))
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .monospacedDigit()
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.ultraThinMaterial)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
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
            }
        }
    }

    // MARK: - Transacciones
    private var transactionsList: some View {
        let expenses = filteredExpenses()
        return List {
            // Selector y filtros como primera sección
            Section {
                selector
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .padding(.bottom, 10)
                filtersBar
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
            }

            // Sección de contenido según segmento
            if selected == .transacciones {
                Section {
                    // Encabezado "Transacciones"
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundStyle(.blue)
                        Text("Transacciones")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        Spacer()
                        Text("\(expenses.count)")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.bottom, 8)

                    if expenses.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(.blue)
                            Text("Aún no hay gastos en el periodo seleccionado")
                                .font(.system(.subheadline))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 32)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    } else {
                        ForEach(expenses, id: \.id) { e in
                            HStack(spacing: 12) {
                                Image(systemName: symbolForCategory(e.category))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(e.title ?? e.category)
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        .lineLimit(1)
                                    Text(shortDate(e.date))
                                        .font(.system(.caption, design: .default))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(formatAmount(e.amountInCents, currencyCode: e.currencyCode))
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .monospacedDigit()
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.ultraThinMaterial)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                            .padding(.vertical, 6)
                            .contextMenu {
                                Button(role: .destructive) { askDelete(e) } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) { askDelete(e) } label: {
                                    Image(systemName: "trash")
                                }
                                Button { startEditing(e) } label: {
                                    Image(systemName: "pencil")
                                }
                                .tint(.blue)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            } else if selected == .resumen {
                Section {
                    summaryView
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }
            } else if selected == .distribucion {
                Section {
                    let breakdown = categoriesBreakdown(expenses)
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
                                colors: top5.enumerated().map { colorForIndex($0.offset) },
                                lineWidth: 22
                            )
                            .frame(height: 220)

                            VStack(spacing: 10) {
                                ForEach(Array(top5.enumerated()), id: \.offset) { idx, item in
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(colorForIndex(idx))
                                            .frame(width: 10, height: 10)
                                        Text(item.name)
                                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                            .lineLimit(1)
                                        Spacer()
                                        HStack(spacing: 8) {
                                            Text(formatAmount(item.total, currencyCode: item.currency))
                                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                                .monospacedDigit()
                                            Text(formatPercent(Double(item.total) / Double(totalAll)))
                                                .font(.system(.caption, design: .rounded, weight: .medium))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedCategoryName = item.name
                                            selected = .transacciones
                                        }
                                    }
                                }

                                let more = Array(breakdown.dropFirst(top5.count))
                                if !more.isEmpty {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            showAllCategories.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Text(showAllCategories ? "Ocultar otras" : "Mostrar todas")
                                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                            Spacer()
                                            Image(systemName: showAllCategories ? "chevron.up" : "chevron.down")
                                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, 6)

                                    if showAllCategories {
                                        Divider()
                                            .opacity(0.15)
                                            .padding(.vertical, 4)

                                        ForEach(Array(more.enumerated()), id: \.offset) { ridx, ritem in
                                            VStack(spacing: 6) {
                                                HStack(spacing: 12) {
                                                    Circle()
                                                        .fill(colorForIndex(ridx + top5.count))
                                                        .frame(width: 10, height: 10)
                                                    Text(ritem.name)
                                                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                                                        .lineLimit(1)
                                                    Spacer()
                                                    HStack(spacing: 8) {
                                                        Text(formatAmount(ritem.total, currencyCode: ritem.currency))
                                                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                                            .monospacedDigit()
                                                        Text(formatPercent(Double(ritem.total) / Double(totalAll)))
                                                            .font(.system(.caption, design: .rounded, weight: .medium))
                                                            .foregroundStyle(.secondary)
                                                    }
                                                }
                                                ProgressView(value: Double(ritem.total), total: Double(totalAll))
                                                    .progressViewStyle(.linear)
                                                    .tint(colorForIndex(ridx + top5.count))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    selectedCategoryName = ritem.name
                                                    selected = .transacciones
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

                    // Tarjeta: Gasto total por periodo
                    let currencyOptions = Array(totalsByCurrency(allExpenses).keys).sorted()
                    let buckets = chartBuckets(for: selectedChartRange, currency: selectedChartCurrency)
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
                                    Button(action: { selectedChartRange = r }) {
                                        HStack {
                                            Text(r.rawValue)
                                            if selectedChartRange == r { Spacer(); Image(systemName: "checkmark") }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                    Text(selectedChartRange.rawValue)
                                }
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                            }

                            Menu {
                                ForEach(currencyOptions, id: \.self) { code in
                                    Button(action: { selectedChartCurrency = code }) {
                                        HStack {
                                            Image(systemName: symbolForCurrency(code))
                                            Text(code)
                                            if selectedChartCurrency == code { Spacer(); Image(systemName: "checkmark") }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: symbolForCurrency(selectedChartCurrency))
                                    Text("Moneda: \(selectedChartCurrency)")
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
                                currencyCode: selectedChartCurrency,
                                colors: buckets.enumerated().map { colorForIndex($0.offset) }
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
             } else {
                 Section {
                     RoundedRectangle(cornerRadius: 20)
                         .fill(.thinMaterial)
                         .frame(height: 220)
                         .overlay(
                             VStack(spacing: 8) {
                                 Image(systemName: selected.icon)
                                     .font(.system(size: 28, weight: .medium))
                                     .foregroundStyle(.blue)
                                 Text(selected.rawValue)
                                     .font(.system(.title2, design: .rounded, weight: .bold))
                                     .foregroundStyle(.primary)
                                 Text("Aquí agregaremos gráficos y KPIs de \(selected.rawValue)")
                                     .font(.system(.subheadline, design: .default))
                                     .foregroundStyle(.secondary)
                             }
                         )
                         .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                         .frame(maxWidth: .infinity)
                         .listRowSeparator(.hidden)
                         .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                         .listRowBackground(Color.clear)
                 }
             }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .animation(.easeInOut(duration: 0.25), value: selected)
    }
    
    private func deleteExpense(_ expense: Expense) {
        modelContext.delete(expense)
        do {
            try modelContext.save()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            deleteErrorMessage = "No se pudo eliminar el gasto"
            showDeleteError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    private func askDelete(_ expense: Expense) {
        expensePendingDelete = expense
        showDeleteConfirm = true
    }
    
    private func startEditing(_ expense: Expense) {
        expenseToEdit = expense
    }
    
}

#Preview {
    SpendingDashboardView()
}

private extension SpendingDashboardView {
    func filteredExpenses() -> [Expense] {
        let range = dateInterval(for: selectedPeriod)
        return allExpenses.filter { exp in
            range.contains(exp.date) &&
            (selectedCategoryName == "Todas" || exp.category.lowercased() == selectedCategoryName.lowercased())
        }
    }

    func dateInterval(for period: Period) -> DateInterval {
        let cal = Calendar.current
        let now = Date()
        switch period {
        case .mesActual:
            let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .mesAnterior:
            let currentStart = cal.date(from: cal.dateComponents([.year, .month], from: now))!
            let start = cal.date(byAdding: .month, value: -1, to: currentStart)!
            return DateInterval(start: start, end: currentStart)
        case .tresMeses:
            let currentStart = cal.date(from: cal.dateComponents([.year, .month], from: now))!
            let start = cal.date(byAdding: .month, value: -2, to: currentStart)!
            let end = cal.date(byAdding: .month, value: 1, to: currentStart)!
            return DateInterval(start: start, end: end)
        case .anio:
            let comps = cal.dateComponents([.year], from: now)
            let start = cal.date(from: comps)!
            let end = cal.date(byAdding: .year, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .personalizado:
            // Por ahora usamos mes actual; luego agregamos selector de rango
            let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        }
    }

    // Intervalo anterior (misma duración desplazada hacia atrás)
    func previousDateInterval(for period: Period) -> DateInterval {
        let current = dateInterval(for: period)
        let duration = current.end.timeIntervalSince(current.start)
        let endPrev = current.start
        let startPrev = endPrev.addingTimeInterval(-duration)
        return DateInterval(start: startPrev, end: endPrev)
    }

    // Gastos del periodo anterior con el mismo filtro de categoría
    func previousExpensesForSelectedFilters() -> [Expense] {
        let prevRange = previousDateInterval(for: selectedPeriod)
        return allExpenses.filter { exp in
            prevRange.contains(exp.date) &&
            (selectedCategoryName == "Todas" || exp.category.lowercased() == selectedCategoryName.lowercased())
        }
    }

    // Moneda con mayor peso (para KPIs y proyecciones)
    func mostSignificantCurrency(in totals: [String: Int]) -> String? {
        return totals.max(by: { $0.value < $1.value })?.key
    }

    // Proyección al cierre del periodo según ritmo actual
    func projectedTotal(forCurrentPeriodExpenses expenses: [Expense]) -> (total: Int, currency: String)? {
        let totals = totalsByCurrency(expenses)
        guard let code = mostSignificantCurrency(in: totals) else { return nil }
        let range = dateInterval(for: selectedPeriod)
        let duration = range.end.timeIntervalSince(range.start)
        guard duration > 0 else { return nil }
        let elapsed = min(Date().timeIntervalSince(range.start), duration)
        let ratio = max(0.01, elapsed / duration)
        let currentTotal = totals[code] ?? 0
        let projection = Int(Double(currentTotal) / ratio)
        return (total: projection, currency: code)
    }

    func totalsByCurrency(_ expenses: [Expense]) -> [String: Int] {
        var totals: [String: Int] = [:]
        for e in expenses { totals[e.currencyCode, default: 0] += e.amountInCents }
        return totals
    }

    func topCategory(_ expenses: [Expense]) -> (name: String, total: Int, currency: String)? {
        // Nota: mezcla monedas; tomamos la moneda más frecuente para mostrar
        var sums: [String: (total: Int, currency: String, count: Int)] = [:]
        for e in expenses { sums[e.category, default: (0, e.currencyCode, 0)].total += e.amountInCents; sums[e.category, default: (0, e.currencyCode, 0)].count += 1 }
        let sorted = sums.sorted { $0.value.total > $1.value.total }
        guard let first = sorted.first else { return nil }
        return (name: first.key, total: first.value.total, currency: first.value.currency)
    }

    func formatAmount(_ cents: Int, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let value = Double(cents) / 100.0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    func symbolForCurrency(_ code: String) -> String {
        switch code.uppercased() {
        case "MXN": return "pesosign.circle"
        case "USD": return "dollarsign.circle"
        case "EUR": return "eurosign.circle"
        default: return "banknote"
        }
    }
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

    func shortDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_MX")
        df.setLocalizedDateFormatFromTemplate("d MMM yyyy, HH:mm")
        return df.string(from: date)
    }
    
    // Helpers para Distribución
    func categoriesBreakdown(_ expenses: [Expense]) -> [(name: String, total: Int, currency: String)] {
        var acc: [String : (total: Int, currency: String)] = [:]
        for e in expenses {
            let key = e.category
            let prev = acc[key] ?? (0, e.currencyCode)
            acc[key] = (prev.total + e.amountInCents, prev.currency)
        }
        return acc.map { (name: $0.key, total: $0.value.total, currency: $0.value.currency) }
            .sorted { $0.total > $1.total }
    }
    
    func colorForIndex(_ idx: Int) -> Color {
        let palette: [Color] = [.blue, .green, .orange, .pink, .purple, .teal, .indigo, .cyan]
        return palette[idx % palette.count]
    }
    
    func formatPercent(_ value: Double) -> String {
        let pct = max(0.0, min(1.0, value))
        return String(format: "%.0f%%", pct * 100.0)
    }

    // Aggregación para gráfica de barras
    func chartBuckets(for range: ChartRange, currency: String) -> [(label: String, total: Int)] {
        let cal = Calendar.current
        let now = Date()
        let expenses = allExpenses.filter { $0.currencyCode.uppercased() == currency.uppercased() }
        let dfMonth = DateFormatter(); dfMonth.locale = Locale(identifier: "es_MX"); dfMonth.setLocalizedDateFormatFromTemplate("MMM")
        let dfYear = DateFormatter(); dfYear.locale = Locale(identifier: "es_MX"); dfYear.setLocalizedDateFormatFromTemplate("yyyy")

        func sum(in interval: DateInterval) -> Int {
            expenses.filter { interval.contains($0.date) }.map { $0.amountInCents }.reduce(0, +)
        }

        switch range {
        case .last3Months:
            guard let currentMonth = cal.dateInterval(of: .month, for: now) else { return [] }
            var buckets: [(String, Int)] = []
            for i in stride(from: 2, through: 0, by: -1) {
                guard let start = cal.date(byAdding: .month, value: -i, to: currentMonth.start),
                      let monthInterval = cal.dateInterval(of: .month, for: start) else { continue }
                let label = dfMonth.string(from: monthInterval.start).capitalized
                buckets.append((label, sum(in: monthInterval)))
            }
            return buckets
        case .lastMonthByWeek:
            guard let monthInterval = cal.dateInterval(of: .month, for: now),
                  let weeksRange = cal.range(of: .weekOfMonth, in: .month, for: now) else { return [] }
            var buckets: [(String, Int)] = []
            for week in weeksRange {
                let label = "Sem \(week)"
                let total = expenses.filter {
                    cal.isDate($0.date, equalTo: monthInterval.start, toGranularity: .month) &&
                    cal.isDate($0.date, equalTo: monthInterval.start, toGranularity: .year) &&
                    cal.component(.weekOfMonth, from: $0.date) == week
                }.map { $0.amountInCents }.reduce(0, +)
                buckets.append((label, total))
            }
            return buckets
        case .lastYear:
            guard let currentMonth = cal.dateInterval(of: .month, for: now) else { return [] }
            var buckets: [(String, Int)] = []
            for i in stride(from: 11, through: 0, by: -1) {
                guard let start = cal.date(byAdding: .month, value: -i, to: currentMonth.start),
                      let monthInterval = cal.dateInterval(of: .month, for: start) else { continue }
                let label = dfMonth.string(from: monthInterval.start).capitalized
                buckets.append((label, sum(in: monthInterval)))
            }
            return buckets
        case .last3Years:
            guard let currentYear = cal.dateInterval(of: .year, for: now) else { return [] }
            var buckets: [(String, Int)] = []
            for i in stride(from: 2, through: 0, by: -1) {
                guard let start = cal.date(byAdding: .year, value: -i, to: currentYear.start),
                      let yearInterval = cal.dateInterval(of: .year, for: start) else { continue }
                let label = dfYear.string(from: yearInterval.start)
                buckets.append((label, sum(in: yearInterval)))
            }
            return buckets
        }
    }
}


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
