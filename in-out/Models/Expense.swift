import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var amountInCents: Int
    var date: Date
    var category: String
    var note: String?
    var title: String?
    var currencyCode: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        amountInCents: Int,
        date: Date = .init(),
        category: String,
        note: String? = nil,
        title: String? = nil,
        currencyCode: String = "MXN"
    ) {
        self.id = id
        self.amountInCents = amountInCents
        self.date = date
        self.category = category
        self.note = note
        self.title = title
        self.currencyCode = currencyCode
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }
}

extension Expense {
    var yearMonthKey: String {
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        return String(format: "%04d-%02d", y, m)
    }
}