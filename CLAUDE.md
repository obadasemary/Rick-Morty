# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A modern iOS app built with SwiftUI and Clean Architecture, displaying Rick and Morty characters from the Rick and Morty API. The project uses a multi-modular architecture with Swift Package Manager (SPM), separating concerns across independent packages.

**Tech Stack:** Swift 6.0, iOS 17.0+, SwiftUI, Xcode 16.4+

## Build & Test Commands

### Building the Project
```bash
# Open workspace (required - do not open the .xcodeproj)
open RickMorty.xcworkspace

# Build from command line
xcodebuild -workspace RickMorty.xcworkspace -scheme RickMorty -destination 'platform=iOS Simulator,name=iPhone 15' build

# Build specific package
xcodebuild -workspace RickMorty.xcworkspace -scheme UseCase build
```

### Running Tests
```bash
# Run all tests from command line
xcodebuild test -workspace RickMorty.xcworkspace -scheme RickMorty -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests for a specific package from the workspace root
xcodebuild test -workspace RickMorty.xcworkspace -scheme UseCase -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild test -workspace RickMorty.xcworkspace -scheme FeedView -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild test -workspace RickMorty.xcworkspace -scheme RickMortyNetworkLayer -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests from Xcode: Cmd + U
```

### Running the App
```bash
# From Xcode: Cmd + R
# Ensure you're using a simulator running iOS 17.0+
```

## Architecture Overview

The app follows **Clean Architecture** with strict layer separation. Data flows **unidirectionally** from outer layers (UI) through use cases to the data layer.

### Layer Dependencies (Dependency Direction: Outer → Inner)
```
Presentation Layer (FeedView, CharacterDetailsView, TabBarView)
    ↓
Business Logic Layer (UseCase)
    ↓
Data Layer (RickMortyNetworkLayer, CoreAPI, RickMortyRepository)
```

### Key Architecture Principles

1. **Dependency Injection via DIContainer**: All dependencies are registered in `AppComposition.swift` and resolved through `DIContainer`. The DI container is `@MainActor` and `@Observable`.

2. **Builder Pattern for Features**: Each feature module has a `Builder` class (e.g., `FeedBuilder`, `CharacterDetailsBuilder`) that constructs views with their dependencies from the DI container.

3. **Protocol-Oriented Design**: All layers communicate through protocols:
   - `NetworkService` → abstracts HTTP client
   - `FeedRepositoryProtocol` → abstracts data access
   - `FeedUseCaseProtocol` → abstracts business logic
   - Routers use protocols for navigation

4. **Actor Isolation**: Most classes are `@MainActor` to ensure UI updates happen on the main thread. This is critical - do not remove `@MainActor` annotations without careful consideration.

5. **Observable Macro**: SwiftUI state management uses `@Observable` macro instead of `ObservableObject`. ViewModels and builders are marked `@Observable`.

## Module Structure

### Core Infrastructure
- **RickMortyNetworkLayer**: Generic HTTP client with `NetworkService` protocol and `URLSessionNetworkService` implementation
- **CoreAPI**: Defines `RickMortyEndpoint` enum implementing `Endpoint` protocol (baseURL: `https://rickandmortyapi.com/api`)
- **RickMortyRepository**: Implements `FeedRepositoryProtocol`, orchestrates network calls
- **DependencyContainer**: Simple service locator with `register()` and `requireResolve()` methods

### Business Logic
- **UseCase**: Contains `FeedUseCase` for fetching paginated character lists with optional status filtering. Includes domain models (`CharacterResponse`, `CharactersPageResponse`) and adapters for mapping DTOs to view models.

### Presentation Features
- **FeedView**: SwiftUI character list with infinite scroll pagination and status filtering. Uses `FeedViewModel` with state machine pattern (idle, loading, loaded, error, loadingMore).
- **CharacterDetailsView**: Character detail screen
- **TabBarView**: Main tab-based navigation using SUIRouting library
- **RickMortyUI**: Shared UI components (`CharacterView`, `ErrorView`, `FiltersView`, `CharacterTableViewCell`)

### Utilities
- **DevPreview**: Provides a singleton `DevPreview.shared.container` for SwiftUI previews with real dependencies

## Critical Implementation Details

### Dependency Resolution Pattern
```swift
// In AppComposition.swift - registration order matters:
container.register(NetworkService.self, URLSessionNetworkService(session: .shared))
let networkService = try container.requireResolve(NetworkService.self)
container.register(FeedRepositoryProtocol.self, FeedRepository(networkService: networkService))
container.register(FeedUseCaseProtocol.self, FeedUseCase(container: container))
```

### Builder Pattern Usage
```swift
// Features are composed via builders that receive the DI container
let builder = FeedBuilder(container: container)
let view = builder.buildFeedView(router: router)
```

### ViewModel State Management
ViewModels use an enum-based state machine pattern:
```swift
enum State {
    case idle
    case loading
    case loaded([CharacterAdapter])
    case error(FeedError)
    case loadingMore([CharacterAdapter])
}
```

### Pagination Flow
- First load: `page=1`, state transitions to `.loading`
- Load more: `page=currentPage+1`, state transitions to `.loadingMore(existingCharacters)`
- Filtering: resets to `page=1`, clears characters array
- Guard with `isLoading` flag to prevent concurrent requests

### Navigation with SUIRouting
The app uses the SUIRouting library (external dependency) for declarative routing. Routers conform to protocols and use the `Router` object to push/present views.

### Error Mapping
ViewModels map generic errors to domain-specific error types using type casting:
- `URLError` → `FeedError.network` (network connectivity issues)
- `DecodingError` → `FeedError.decoding` (JSON parsing failures)
- NSError with HTTPStatusCode → `FeedError.server(status:)` (HTTP errors)
- Other errors → `FeedError.unknown(message:)` (unclassified errors)
- ViewModels provide user-friendly error messages via computed properties

## Common Development Tasks

### Adding a New Feature Module
1. Create new SPM package in workspace root
2. Add to `RickMorty.xcworkspace` via Xcode (File → Add Package → Add Local...)
3. Define protocol interfaces in UseCase if needed
4. Create Builder class following the pattern in `FeedBuilder`
5. Register dependencies in `AppComposition` or use `DevPreview.shared.container` for previews

### Adding Network Endpoints
1. Add case to `RickMortyEndpoint` enum in CoreAPI package
2. Implement `path`, `method`, `parameters`, `contentType` for the new case
3. Create response DTO models in UseCase
4. Add repository method implementing the data fetch
5. Create or extend UseCase to expose business logic

### Testing Strategy
- **Unit Tests**: Each package has its own `Tests/` directory with Swift Testing framework
- **Test Doubles**: Use protocol-based mocks (e.g., `MockNetworkService`, `FakeFeedUseCase`)
- **ViewModel Tests**: Test state transitions and business logic with fake use cases
- **Repository Tests**: Mock `NetworkService` to test data layer in isolation

### Working with SwiftUI Previews
Use `DevPreview.shared.container` which provides real implementations:
```swift
#Preview {
    FeedView(...)
        .environment(FeedBuilder(container: DevPreview.shared.container))
}
```

## Important Constraints

1. **Always use the workspace**: Open `RickMorty.xcworkspace`, never `RickMorty.xcodeproj`
2. **@MainActor is critical**: Most classes are isolated to MainActor for thread safety
3. **Force unwrapping forbidden**: Recent commits show effort to eliminate force unwraps - use safe unwrapping or `requireResolve()` with proper error handling
4. **Protocol-first**: Always define protocols for cross-module dependencies
5. **Builder pattern is mandatory**: Features must be composed via builder classes, not instantiated directly
6. **SUIRouting dependency**: External package for navigation, pinned at version 1.0.7

## API Information

- **Base URL**: `https://rickandmortyapi.com/api`
- **Main Endpoint**: `/character` with optional query params:
  - `page`: Int (1-based pagination)
  - `status`: String ("alive", "dead", "unknown")
- **No authentication required**
- **Response format**: JSON with pagination metadata in `info` object
