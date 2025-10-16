import Foundation

struct CategoryItem: Identifiable, Equatable {
    let id: String
    let name: String
    let symbol: String
}

enum PredefinedCategories {
    static let all: [CategoryItem] = [
        CategoryItem(id: "general", name: "General", symbol: "tag.fill"),
        CategoryItem(id: "comida", name: "Comida", symbol: "fork.knife"),
        CategoryItem(id: "transporte", name: "Transporte", symbol: "car.fill"),
        CategoryItem(id: "servicios", name: "Servicios", symbol: "bolt.fill"),
        CategoryItem(id: "hogar", name: "Hogar", symbol: "house.fill"),
        CategoryItem(id: "entretenimiento", name: "Entretenimiento", symbol: "theatermasks.fill"),
        CategoryItem(id: "salud", name: "Salud", symbol: "cross.case.fill"),
        CategoryItem(id: "educacion", name: "Educación", symbol: "book.fill"),
        CategoryItem(id: "ropa", name: "Ropa", symbol: "tshirt"),
        CategoryItem(id: "otros", name: "Otros", symbol: "ellipsis.circle.fill")
    ]

    static func item(named name: String) -> CategoryItem? {
        all.first { $0.name == name }
    }
}