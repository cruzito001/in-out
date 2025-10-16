import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var symbol: String
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    init(id: UUID = UUID(), name: String, symbol: String, createdAt: Date = Date(), updatedAt: Date = Date(), isArchived: Bool = false) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
    }
}