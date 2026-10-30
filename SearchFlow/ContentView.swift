import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let errorMessage = viewModel.errorMessage {
                    errorBanner(errorMessage)
                }

                List(viewModel.results) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)

                        Text(item.category)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .overlay {
                    emptyState
                }
                .overlay(alignment: .top) {
                    if viewModel.isSearching,
                       !viewModel.results.isEmpty {
                        ProgressView()
                            .padding(10)
                            .background(.regularMaterial)
                            .clipShape(Capsule())
                            .padding()
                    }
                }
            }
            .navigationTitle("Product Search")
            .searchable(
                text: $viewModel.query,
                prompt: "Search products or categories"
            )
        }
    }
}

private extension ContentView {
    @ViewBuilder
    var emptyState: some View {
        if viewModel.results.isEmpty {
            if viewModel.isSearching {
                ProgressView("Searching…")
            } else if viewModel.query.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty {
                ContentUnavailableView(
                    "Search Products",
                    systemImage: "magnifyingglass",
                    description: Text(
                        "Enter a product name or category."
                    )
                )
            } else if viewModel.errorMessage == nil {
                ContentUnavailableView.search(
                    text: viewModel.query
                )
            }
        }
    }

    func errorBanner(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .font(.footnote)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.red.opacity(0.1))
    }
}

#Preview {
    ContentView(
        viewModel: SearchViewModel(
            service: LocalSearchService()
        )
    )
}
