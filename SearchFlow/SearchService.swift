import Foundation

nonisolated protocol SearchService: Sendable {
    func search(query: String) async throws -> [SearchItem]
}

import Foundation

nonisolated struct LocalSearchService: SearchService {
    private let items: [SearchItem]
    private let delay: Duration

    init(
        items: [SearchItem] = SearchItem.samples,
        delay: Duration = .milliseconds(300)
    ) {
        self.items = items
        self.delay = delay
    }

    func search(query: String) async throws -> [SearchItem] {
        try await Task.sleep(for: delay)
        try Task.checkCancellation()

        let normalizedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !normalizedQuery.isEmpty else {
            return []
        }

        return items.filter { item in
            item.title.localizedCaseInsensitiveContains(
                normalizedQuery
            )
            || item.category.localizedCaseInsensitiveContains(
                normalizedQuery
            )
        }
    }
}
