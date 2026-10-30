import SwiftUI

@main
struct SearchFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: SearchViewModel(
                    service: LocalSearchService()
                )
            )
        }
    }
}
