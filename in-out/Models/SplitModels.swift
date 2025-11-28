//
//  SplitModels.swift
//  in-out
//
//  Created by Alan Cruz
//

import Foundation
import SwiftData

@Model
final class SplitGroup {
    var id: UUID
    var name: String
    var date: Date
    var isArchived: Bool
    
    // Relaciones
    @Relationship(deleteRule: .cascade) var members: [SplitMember] = []
    @Relationship(deleteRule: .cascade) var expenses: [SplitExpense] = []
    
    init(id: UUID = UUID(), name: String, date: Date = Date(), isArchived: Bool = false) {
        self.id = id
        self.name = name
        self.date = date
        self.isArchived = isArchived
    }
}

@Model
final class SplitMember {
    var id: UUID
    var name: String
    var colorHex: String // Para el avatar
    
    // Relación inversa (opcional pero útil)
    var group: SplitGroup?
    
    init(id: UUID = UUID(), name: String, colorHex: String = "007AFF") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}

@Model
final class SplitExpense {
    var id: UUID
    var title: String
    var amount: Double
    var date: Date
    
    // Quién pagó
    @Relationship var paidBy: SplitMember?
    
    // Quiénes se benefician (IDs para simplificar la lógica de cálculo)
    // SwiftData a veces complica arrays de relaciones primitivas,
    // así que guardamos los UUIDs de los miembros involucrados.
    var splitAmongMemberIDs: [UUID] = []
    
    var group: SplitGroup?
    
    init(id: UUID = UUID(), title: String, amount: Double, date: Date = Date(), paidBy: SplitMember?, splitAmongIDs: [UUID]) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.paidBy = paidBy
        self.splitAmongMemberIDs = splitAmongIDs
    }
}

