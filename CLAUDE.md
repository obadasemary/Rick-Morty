# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A modern iOS app built with SwiftUI and Clean Architecture, displaying Rick and Morty characters from the Rick and Morty API. The project uses a multi-modular architecture with Swift Package Manager (SPM), featuring a **hybrid SwiftUI/UIKit implementation** to demonstrate both frameworks working together.

**Tech Stack:** Swift 6.1+, iOS 17.0+ (packages) / iOS 18.5 (main app), SwiftUI + UIKit, Xcode 16+

## Build & Test Commands

### Building the Project
```bash
# Open workspace (required - do not open the .xcodeproj)
open RickMorty.xcworkspace

# Build from command line (using iPhone 15 Pro simulator as in CI)
xcodebuild -workspace RickMorty.xcworkspace -scheme RickMorty -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Build specific package
xcodebuild -workspace RickMorty.xcworkspace -scheme UseCase build

# Build package from its directory using SPM
cd UseCase && swift build
```

### Running Tests
```bash
# Run all unit tests from command line
xcodebuild test -workspace RickMorty.xcworkspace -scheme RickMorty -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:RickMortyTests

# Run UI tests (note: these are non-blocking in CI due to timeout risks)
xcodebuild test -workspace RickMorty.xcworkspace -scheme RickMorty -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:RickMortyUITests -parallel-testing-enabled NO

# Run tests for a specific package using SPM
cd UseCase && swift test
cd RickMortyRepository && swift test
cd RickMortyNetworkLayer && swift test

# Run tests from Xcode: Cmd + U
```

### Running the App
```bash
# From Xcode: Cmd + R
# Ensure you're using a simulator running iOS 17.0+ (or iOS 18.5 for main app target)
```

### CI/CD
The project uses GitHub Actions with a comprehensive CI pipeline ([.github/workflows/ci.yml](.github/workflows/ci.yml)) that:
- Runs unit tests on the main app
- Tests individual SPM packages in a matrix
- Performs integration build tests
- Runs UI tests (with timeout protection and non-blocking mode)
- Validates Package.swift files and SPM dependencies
- Uses module cache cleaning to prevent stale header issues

## Architecture Overview

The app follows **Clean Architecture** with strict layer separation. Data flows **unidirectionally** from outer layers (UI) through use cases to the data layer.

### Layer Dependencies (Dependency Direction: Outer → Inner)
```
Presentation Layer (FeedView [SwiftUI], FeedListView [UIKit], CharacterDetailsView, TabBarView)
    ↓
Builder Pattern (FeedBuilder, FeedListBuilder, CharacterDetailsBuilder, TabBarBuilder)
    ↓
Router + ViewModel (@Observable, @MainActor)
    ↓
Business Logic Layer (UseCase)
    ↓
Data Layer (RickMortyRepository)
    ↓
Network Layer (RickMortyNetworkLayer, CoreAPI)
```

### Key Architecture Principles

1. **Dependency Injection via DIContainer**: All dependencies are registered in [AppComposition.swift](RickMorty/App/AppComposition.swift) and resolved through `DIContainer`. The DI container is `@MainActor` and `@Observable`.

2. **Builder Pattern for Features**: Each feature module has a `Builder` class (e.g., `FeedBuilder`, `FeedListBuilder`, `CharacterDetailsBuilder`, `TabBarBuilder`) that constructs views with their dependencies from the DI container. Builders are `@Observable` and `@MainActor`.

3. **Protocol-Oriented Design**: All layers communicate through protocols:
   - `NetworkService` → abstracts HTTP client
   - `FeedRepositoryProtocol` → abstracts data access
   - `FeedUseCaseProtocol` → abstracts business logic
   - `FeedRouterProtocol`, `FeedListRouterProtocol` → abstract navigation

4. **Actor Isolation**: Most classes are `@MainActor` to ensure UI updates happen on the main thread. This is critical - do not remove `@MainActor` annotations without careful consideration.

5. **Observable Macro**: SwiftUI state management uses `@Observable` macro instead of `ObservableObject`. ViewModels, builders, and the DI container are marked `@Observable`.

6. **Hybrid SwiftUI + UIKit**: The app demonstrates both frameworks:
   - **SwiftUI**: `FeedView` with `ScrollView` and `LazyVStack`
   - **UIKit**: `FeedListViewController` with `UITableViewController`
   - Both share the same business logic and state management pattern
   - UIKit views use manual observation tracking with `withObservationTracking`

## Module Structure (11 Packages)

### Core Infrastructure
- **RickMortyNetworkLayer**: Generic HTTP client with `NetworkService` protocol and `URLSessionNetworkService` implementation. No external networking dependencies (uses URLSession).
- **CoreAPI**: Defines `RickMortyEndpoint` enum implementing `Endpoint` protocol (baseURL: `https://rickandmortyapi.com/api`).
- **RickMortyRepository**: Implements `FeedRepositoryProtocol`, orchestrates network calls. Marked `@Observable` for change tracking.
- **DependencyContainer**: Simple service locator with `register()`, `resolve()`, and `requireResolve()` methods. Supports both direct instance and factory closure registration.

### Business Logic
- **UseCase**: Contains `FeedUseCase` for fetching paginated character lists with optional status filtering. Includes:
  - Domain models: `CharacterResponse` (DTO), `CharactersPageResponse`
  - Adapters: `CharacterAdapter` (view model representation)
  - Error types: `FeedError` enum with user-friendly messages
  - Protocols: `FeedRepositoryProtocol`, `FeedUseCaseProtocol`

### Presentation Features
- **FeedView**: SwiftUI character list with infinite scroll pagination and status filtering. Uses `FeedViewModel` with state machine pattern.
- **FeedListView**: UIKit character list with `UITableViewController`. Uses `FeedListViewModel` (identical logic to `FeedViewModel`). Demonstrates UIKit integration with `@Observable` using `withObservationTracking`.
- **CharacterDetailsView**: Character detail screen showing full character information.
- **TabBarView**: Main tab-based navigation with two tabs:
  - Tab 1: SwiftUI `FeedView`
  - Tab 2: UIKit `FeedListViewController`
- **RickMortyUI**: Shared UI components:
  - `CharacterView` - character card component
  - `ErrorView` - error display with retry
  - `FiltersView` - status filter chips
  - `CharacterTableViewCell` - UIKit table cell
  - `CachedAsyncImage` - custom async image with caching via `ImageCache`

### Utilities
- **DevPreview**: Provides `DevPreview.shared.container` singleton for SwiftUI previews with real dependencies. Includes pre-configured DI container for development.

## Critical Implementation Details

### Dependency Resolution Pattern
```swift
// In AppComposition.swift - registration order matters:
container.register(NetworkService.self, URLSessionNetworkService(session: .shared))
let networkService = try container.requireResolve(NetworkService.self)
container.register(FeedRepositoryProtocol.self, FeedRepository(networkService: networkService))
let feedRepository = try container.requireResolve(FeedRepositoryProtocol.self)
container.register(FeedUseCaseProtocol.self, FeedUseCase(feedRepository: feedRepository))
```

### Builder Pattern Usage
```swift
// Features are composed via builders that receive the DI container
let feedBuilder = FeedBuilder(container: container)
let feedListBuilder = FeedListBuilder(container: container)

// In TabBarView:
RouterView { router in
    feedBuilder.buildFeedView(router: router)
}
.tabItem { Label("SwiftUI", systemImage: "list.bullet") }

RouterView { router in
    feedListBuilder.buildFeedListViewController(router: router)
}
.tabItem { Label("UIKit", systemImage: "tablecells") }
```

### ViewModel State Management
Both `FeedViewModel` and `FeedListViewModel` use an enum-based state machine pattern:
```swift
enum State {
    case idle
    case loading
    case loaded([CharacterAdapter])
    case error(FeedError)
    case loadingMore([CharacterAdapter])
}
```

State transitions are explicit and testable. The `isLoading` computed property prevents concurrent requests.

### UIKit Integration with @Observable
```swift
// In FeedListViewController
func startObservingViewModel() {
    withObservationTracking {
        _ = viewModel.state
        _ = viewModel.characters
    } onChange: {
        Task { @MainActor in
            self?.renderState()
            self?.startObservingViewModel()
        }
    }
}
```

This pattern allows UIKit views to react to changes in `@Observable` ViewModels without using `ObservableObject` or Combine.

### Pagination Flow
- First load: `page=1`, state transitions to `.loading`
- Load more: `page=currentPage+1`, state transitions to `.loadingMore(existingCharacters)`
- Filtering: resets to `page=1`, clears characters array
- Guard with `isLoading` flag to prevent concurrent requests
- Both SwiftUI and UIKit implementations share identical pagination logic

### Navigation with SUIRouting
The app uses the SUIRouting library v1.0.6+ (external dependency from `https://github.com/obadasemary/SUIRouting.git`) for declarative routing.

Router implementation pattern:
```swift
@MainActor
struct FeedRouter: FeedRouterProtocol {
    let router: Router
    let characterDetailsBuilder: CharacterDetailsBuilder

    func showCharacterDetails(characterDetailsAdapter: CharacterAdapter) {
        router.showScreen(.push) { innerRouter in
            characterDetailsBuilder.buildCharacterDetailsView(
                router: innerRouter,
                characterDetailsAdapter: characterDetailsAdapter
            )
        }
    }
}
```

Navigation methods:
- `router.showScreen(.push)` → push to navigation stack
- `innerRouter.dismissScreen()` → pop from stack

**Known Issue**: SUIRouting has platform compatibility issues on macOS (requires iOS-only APIs like `fullScreenCover`), which is why FeedView tests may be skipped in CI when running on macOS.

### Error Mapping
ViewModels map generic errors to domain-specific error types:
```swift
func mapError(_ error: Error) -> FeedError {
    if error is URLError {
        return .network
    }
    if error is DecodingError {
        return .decoding
    }
    if let nsError = error as NSError,
       let httpStatus = nsError.userInfo["HTTPStatusCode"] as? Int {
        return .server(status: httpStatus)
    }
    return .unknown(message: error.localizedDescription)
}
```

Error types:
- `FeedError.network` → network connectivity issues
- `FeedError.decoding` → JSON parsing failures
- `FeedError.server(status:)` → HTTP errors (4xx, 5xx)
- `FeedError.unknown(message:)` → unclassified errors

ViewModels provide user-friendly error messages via computed properties.

### UI Testing Support
The app includes `UITestFeedRepository` in [AppComposition.swift](RickMorty/App/AppComposition.swift) for deterministic UI tests:
```swift
if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
    container.register(FeedRepositoryProtocol.self, UITestFeedRepository())
}
```

This provides consistent mock data when running UI tests, making tests deterministic and preventing flakiness.

### Image Caching
Custom image loading with `CachedAsyncImage`:
```swift
CachedAsyncImage(url: URL(string: character.image)) { phase in
    switch phase {
    case .success(let image):
        image.resizable().aspectRatio(contentMode: .fill)
    case .failure:
        Image(systemName: "exclamationmark.triangle")
    case .empty:
        ProgressView()
    @unknown default:
        EmptyView()
    }
}
```

Uses `ImageCache` actor for thread-safe caching with `NSCache` underneath.

## Common Development Tasks

### Adding a New Feature Module
1. Create new SPM package in workspace root:
   ```bash
   mkdir MyNewFeature
   cd MyNewFeature
   swift package init --type library --name MyNewFeature
   ```
2. Add to `RickMorty.xcworkspace` via Xcode (File → Add Package → Add Local...)
3. Define protocol interfaces in UseCase if needed
4. Create Builder class following the pattern in `FeedBuilder` or `FeedListBuilder`
5. Register dependencies in `AppComposition` or use `DevPreview.shared.container` for previews
6. Add to main app's Package.swift dependencies

### Adding Network Endpoints
1. Add case to `RickMortyEndpoint` enum in [CoreAPI/Sources/CoreAPI/RickMortyEndpoint.swift](CoreAPI/Sources/CoreAPI/RickMortyEndpoint.swift)
2. Implement required properties: `path`, `method`, `parameters`, `contentType`
3. Create response DTO models in [UseCase/Sources/UseCase/FeedUseCase/Entities/](UseCase/Sources/UseCase/FeedUseCase/Entities/)
4. Add repository method implementing the data fetch
5. Create or extend UseCase to expose business logic
6. Add adapters to convert DTOs to view models if needed

### Testing Strategy
- **Testing Framework**: Swift Testing (modern async-friendly framework using `@Test` and `@Suite` macros)
- **Unit Tests**: Each package has its own `Tests/` directory
- **Test Doubles**: Use protocol-based mocks:
  - `FakeFeedUseCase` - mock use case for ViewModel tests
  - `MockNetworkService` - mock network layer for Repository tests
  - `MockURLProtocol` - URLSession testing
  - `SpyRouter` - spy pattern for Router tests
- **ViewModel Tests**: Test state transitions and business logic with fake use cases
- **Repository Tests**: Mock `NetworkService` to test data layer in isolation
- **UI Tests**: Located in `RickMortyUITests/` directory, use `-ui-testing` flag to enable mock data

Test pattern example:
```swift
@MainActor
@Suite("FeedViewModel • Logic Tests")
struct FeedViewModelTests {
    @Test("Use case execution with success")
    func testUseCaseExecutionSuccess() async throws {
        let fakeUseCase = FakeFeedUseCase()
        let viewModel = FeedViewModel(useCase: fakeUseCase, router: SpyRouter())

        await viewModel.loadData()

        #expect(viewModel.state == .loaded)
    }
}
```

### Working with SwiftUI Previews
Use `DevPreview.shared.container` which provides real implementations:
```swift
#Preview {
    let container = DevPreview.shared.container
    let builder = FeedBuilder(container: container)

    RouterView { router in
        builder.buildFeedView(router: router)
    }
}
```

For UIKit previews:
```swift
#Preview {
    let container = DevPreview.shared.container
    let builder = FeedListBuilder(container: container)

    RouterView { router in
        builder.buildFeedListViewController(router: router)
    }
}
```

### Working with UIKit + @Observable
When integrating UIKit with `@Observable` ViewModels:
1. Use `withObservationTracking` to observe changes
2. Create a recursive observation pattern:
   ```swift
   func startObservingViewModel() {
       withObservationTracking {
           _ = viewModel.state  // Read observed properties
       } onChange: {
           Task { @MainActor in
               self?.renderState()
               self?.startObservingViewModel()  // Re-observe
           }
       }
   }
   ```
3. Start observation in `viewDidLoad()`
4. Avoid using `ObservableObject` or Combine - stick with `@Observable`

## Important Constraints

1. **Always use the workspace**: Open `RickMorty.xcworkspace`, never `RickMorty.xcodeproj` directly
2. **@MainActor is critical**: Most classes are isolated to MainActor for thread safety. Do not remove `@MainActor` annotations without careful consideration
3. **Force unwrapping forbidden**: Use safe unwrapping or `requireResolve()` with proper error handling. Recent commits show effort to eliminate force unwraps
4. **Protocol-first**: Always define protocols for cross-module dependencies
5. **Builder pattern is mandatory**: Features must be composed via builder classes, not instantiated directly
6. **SUIRouting dependency**: External package for navigation, version 1.0.6+ (not 1.0.7). Has known macOS compatibility issues
7. **No external networking libraries**: Uses URLSession directly, no Alamofire or other dependencies
8. **Swift 6 language mode**: Strict concurrency checking is enabled
9. **Use Swift Testing**: Modern testing framework with `@Test` and `@Suite`, not XCTest
10. **Code duplication**: `FeedViewModel` and `FeedListViewModel` have identical logic (intentional for demonstration)

## API Information

- **Base URL**: `https://rickandmortyapi.com/api`
- **Main Endpoint**: `/character` with optional query params:
  - `page`: Int (1-based pagination, required)
  - `status`: String (optional: "alive", "dead", "unknown")
- **No authentication required**
- **Response format**: JSON with pagination metadata in `info` object:
  ```json
  {
    "info": {
      "count": 826,
      "pages": 42,
      "next": "https://rickandmortyapi.com/api/character?page=2",
      "prev": null
    },
    "results": [...]
  }
  ```

## Known Issues & CI Considerations

1. **SUIRouting macOS compatibility**: FeedView and TabBarView packages may fail to build/test on macOS due to SUIRouting using iOS-only APIs (`fullScreenCover`, navigation APIs). CI handles this gracefully with `continue-on-error: true`.

2. **UI test timeouts**: UI tests are non-blocking in CI with timeout protection (30 minutes job timeout, 25 minutes test timeout, 120 seconds per test). Tests use deterministic mock data via `-ui-testing` flag.

3. **Module cache issues**: CI cleans the module cache (`~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex`) to prevent stale precompiled header issues.

4. **Parallel testing disabled for UI tests**: Use `-parallel-testing-enabled NO` for UI tests to reduce flakiness.

5. **Swift version discrepancy**: Xcode project shows `SWIFT_VERSION = 5.0` in project settings, but packages use Swift 6.1 tools version. This is a Xcode project setting quirk - the actual Swift version used is 6.1+.

## File Structure Reference

### Key Files by Layer

**Main App:**
- [RickMorty/App/AppComposition.swift](RickMorty/App/AppComposition.swift) - Central composition root
- [RickMorty/App/AppDelegate.swift](RickMorty/App/AppDelegate.swift) - App lifecycle
- [RickMorty/App/RickMortyApp.swift](RickMorty/App/RickMortyApp.swift) - SwiftUI app entry point

**Network Layer:**
- [RickMortyNetworkLayer/Sources/RickMortyNetworkLayer/NetworkService.swift](RickMortyNetworkLayer/Sources/RickMortyNetworkLayer/NetworkService.swift) - protocol
- [RickMortyNetworkLayer/Sources/RickMortyNetworkLayer/URLSessionNetworkService.swift](RickMortyNetworkLayer/Sources/RickMortyNetworkLayer/URLSessionNetworkService.swift) - implementation
- [CoreAPI/Sources/CoreAPI/RickMortyEndpoint.swift](CoreAPI/Sources/CoreAPI/RickMortyEndpoint.swift) - endpoint definitions

**Repository Layer:**
- [RickMortyRepository/Sources/RickMortyRepository/FeedRepository.swift](RickMortyRepository/Sources/RickMortyRepository/FeedRepository.swift) - data access

**Business Logic:**
- [UseCase/Sources/UseCase/FeedUseCase/UseCase/FeedUseCase.swift](UseCase/Sources/UseCase/FeedUseCase/UseCase/FeedUseCase.swift) - use case implementation
- [UseCase/Sources/UseCase/FeedUseCase/Interfaces/](UseCase/Sources/UseCase/FeedUseCase/Interfaces/) - protocol definitions
- [UseCase/Sources/UseCase/FeedUseCase/Entities/](UseCase/Sources/UseCase/FeedUseCase/Entities/) - DTOs and domain models
- [UseCase/Sources/UseCase/FeedUseCase/Adapter/](UseCase/Sources/UseCase/FeedUseCase/Adapter/) - view model adapters

**SwiftUI Feature:**
- [FeedView/Sources/FeedView/FeedView.swift](FeedView/Sources/FeedView/FeedView.swift) - SwiftUI character list
- [FeedView/Sources/FeedView/FeedViewModel.swift](FeedView/Sources/FeedView/FeedViewModel.swift) - SwiftUI view model
- [FeedView/Sources/FeedView/FeedBuilder.swift](FeedView/Sources/FeedView/FeedBuilder.swift) - feature builder
- [FeedView/Sources/FeedView/FeedRouter.swift](FeedView/Sources/FeedView/FeedRouter.swift) - navigation router

**UIKit Feature:**
- [FeedListView/Sources/FeedListView/FeedListViewController.swift](FeedListView/Sources/FeedListView/FeedListViewController.swift) - UIKit table view controller
- [FeedListView/Sources/FeedListView/FeedListViewModel.swift](FeedListView/Sources/FeedListView/FeedListViewModel.swift) - UIKit view model
- [FeedListView/Sources/FeedListView/FeedListBuilder.swift](FeedListView/Sources/FeedListView/FeedListBuilder.swift) - feature builder
- [FeedListView/Sources/FeedListView/FeedListRouter.swift](FeedListView/Sources/FeedListView/FeedListRouter.swift) - navigation router

**Shared UI:**
- [RickMortyUI/Sources/RickMortyUI/Components/](RickMortyUI/Sources/RickMortyUI/Components/) - reusable UI components

**Dependency Injection:**
- [DependencyContainer/Sources/DependencyContainer/DependencyContainer.swift](DependencyContainer/Sources/DependencyContainer/DependencyContainer.swift) - service locator

**Testing:**
- [RickMortyUITests/](RickMortyUITests/) - UI tests
- `*/Tests/` - Unit tests for each package
