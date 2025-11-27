//
//  DashboardModels.swift
//  in-out
//
//  Created by Alan Cruz
//

import Foundation

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

