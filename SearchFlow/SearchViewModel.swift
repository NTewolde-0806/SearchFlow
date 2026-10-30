import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = "" {
        didSet {
            scheduleSearch()
        }
    }

    @Published private(set) var results: [SearchItem] = []
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?

    private let service: any SearchService
    private let debounceDuration: Duration

    private var searchTask: Task<Void, Never>?
    private var activeRequestID: UUID?

    init(
        service: any SearchService,
        debounceDuration: Duration = .milliseconds(300)
    ) {
        self.service = service
        self.debounceDuration = debounceDuration
    }

    func cancel() {
        searchTask?.cancel()
        searchTask = nil
        activeRequestID = nil
        isSearching = false
    }
}

private extension SearchViewModel {
    func scheduleSearch() {
        searchTask?.cancel()

        let normalizedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let requestID = UUID()
        activeRequestID = requestID
        errorMessage = nil

        guard !normalizedQuery.isEmpty else {
            searchTask = nil
            results = []
            isSearching = false
            return
        }

        let service = self.service
        let debounceDuration = self.debounceDuration

        searchTask = Task { [weak self] in
            do {
                try await Task.sleep(for: debounceDuration)

                guard let self,
                      self.activeRequestID == requestID else {
                    return
                }

                self.isSearching = true

                let newResults = try await service.search(
                    query: normalizedQuery
                )

                guard self.activeRequestID == requestID else {
                    return
                }

                self.results = newResults
                self.isSearching = false
            } catch is CancellationError {
                guard let self,
                      self.activeRequestID == requestID else {
                    return
                }

                self.isSearching = false
            } catch {
                guard let self,
                      self.activeRequestID == requestID else {
                    return
                }

                self.errorMessage = error.localizedDescription
                self.isSearching = false
            }
        }
    }
}
