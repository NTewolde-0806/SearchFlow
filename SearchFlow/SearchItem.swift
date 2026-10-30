import Foundation

struct SearchItem: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let category: String

    init(
        id: UUID = UUID(),
        title: String,
        category: String
    ) {
        self.id = id
        self.title = title
        self.category = category
    }
}

extension SearchItem {
    static let samples: [SearchItem] = [
        SearchItem(title: "Trail Backpack", category: "Travel"),
        SearchItem(title: "Travel Mug", category: "Kitchen"),
        SearchItem(title: "Desk Lamp", category: "Office"),
        SearchItem(title: "Running Shoes", category: "Fitness"),
        SearchItem(title: "Wireless Keyboard", category: "Technology"),
        SearchItem(title: "Camping Lantern", category: "Outdoors")
    ]
}
