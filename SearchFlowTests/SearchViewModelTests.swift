import XCTest
@testable import SearchFlow

final class SearchViewModelTests: XCTestCase {
    @MainActor
    func testRapidInputSearchesOnlyFinalQuery() async throws {
        let service = ControlledSearchService()

        let viewModel = SearchViewModel(
            service: service,
            debounceDuration: .milliseconds(100)
        )

        let expectedResults = [
            SearchItem(
                title: "Travel Mug",
                category: "Kitchen"
            )
        ]

        viewModel.query = "t"
        viewModel.query = "tr"
        viewModel.query = "travel"

        // Wait beyond the debounce interval.
        try await Task.sleep(for: .milliseconds(200))

        let recordedQueries = await service.recordedQueries()

        XCTAssertEqual(recordedQueries, ["travel"])

        await service.succeed(
            requestIndex: 0,
            with: expectedResults
        )

        await allowStateUpdates()

        XCTAssertEqual(viewModel.results, expectedResults)
    }

    @MainActor
    func testOlderResponseCannotOverwriteNewerResults() async {
        let service = ControlledSearchService()

        let viewModel = SearchViewModel(
            service: service,
            debounceDuration: .zero
        )

        let oldResults = [
            SearchItem(
                title: "Old Result",
                category: "Old"
            )
        ]

        let newResults = [
            SearchItem(
                title: "New Result",
                category: "New"
            )
        ]

        // Start the first request.
        viewModel.query = "old"
        await service.waitUntilStarted(requestIndex: 0)

        // Replace it with a newer request.
        viewModel.query = "new"
        await service.waitUntilStarted(requestIndex: 1)

        // Complete the newer request first.
        await service.succeed(
            requestIndex: 1,
            with: newResults
        )

        await allowStateUpdates()

        XCTAssertEqual(viewModel.results, newResults)

        // Simulate an uncooperative dependency returning after its
        // request was cancelled.
        await service.succeed(
            requestIndex: 0,
            with: oldResults
        )

        await allowStateUpdates()

        XCTAssertEqual(
            viewModel.results,
            newResults,
            "An older response must not replace newer results"
        )
    }

    @MainActor
    private func allowStateUpdates() async {
        for _ in 0..<20 {
            await Task.yield()
        }
    }
}

private actor ControlledSearchService: SearchService {
    private struct Request {
        let query: String
        let continuation:
            CheckedContinuation<[SearchItem], Never>
    }

    private var requests: [Request] = []

    func search(query: String) async throws -> [SearchItem] {
        await withCheckedContinuation { continuation in
            requests.append(
                Request(
                    query: query,
                    continuation: continuation
                )
            )
        }
    }

    func waitUntilStarted(requestIndex: Int) async {
        while requests.count <= requestIndex {
            await Task.yield()
        }
    }

    func recordedQueries() -> [String] {
        requests.map(\.query)
    }

    func succeed(
        requestIndex: Int,
        with results: [SearchItem]
    ) {
        requests[requestIndex]
            .continuation
            .resume(returning: results)
    }
}
