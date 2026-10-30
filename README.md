# SearchFlow

A focused SwiftUI exercise demonstrating debounced asynchronous search,
dependency injection, cooperative cancellation, and stale-result protection
under Swift 6 concurrency.

All products and search data are fictional.

## What it demonstrates

- SwiftUI search using `searchable`
- Protocol-based dependency injection
- Debouncing rapidly changing search text
- Cancelling replaced asynchronous work
- Preserving existing results during a replacement search
- Request identity to prevent stale responses from publishing
- Actor-isolated test dependencies
- Focused concurrency tests

## Architecture

### SearchItem

A sendable domain model representing a searchable item.

### SearchService

A nonisolated protocol defining the asynchronous search boundary. The
application depends on this abstraction rather than a concrete service.

### LocalSearchService

A local implementation that searches fictional data and simulates network
latency while cooperating with task cancellation.

### SearchViewModel

A `@MainActor` observable object that owns UI state and coordinates:

1. Query normalization
2. Debounce delay
3. Previous-task cancellation
4. Service execution
5. Active-request validation
6. Result or error publication

### ContentView

A SwiftUI interface that renders initial, loading, result, empty, and error
states.

## Why cancellation and request identity are both needed

Cancellation is cooperative. A dependency may ignore cancellation or finish
after cancellation was requested.

Each search therefore receives a unique request identifier. Before publishing
results, the view model verifies that the identifier still matches the active
request. This prevents an older response from overwriting newer results.

## Tests

The project includes focused tests verifying that:

- Rapid input allows only the final debounced query to reach the service.
- A late response from an older request cannot overwrite newer results.

## Requirements

- Xcode with Swift 6 support
- An iOS Simulator supported by the selected deployment target

## Validation

- The application builds and runs.
- Search results match fictional product names and categories.
- Clearing the query resets the interface.
- The full test suite passes.
