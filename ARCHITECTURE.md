# Architecture Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architectural Principles](#architectural-principles)
3. [Layer Structure](#layer-structure)
4. [Module Breakdown](#module-breakdown)
5. [Dependency Management](#dependency-management)
6. [Data Flow](#data-flow)
7. [Design Patterns](#design-patterns)
8. [Navigation](#navigation)
9. [State Management](#state-management)
10. [Testing Strategy](#testing-strategy)
11. [Common Patterns](#common-patterns)

---

## Overview

**RickMorty** is a native iOS application built with **Swift 6.0** and **SwiftUI**, following **Clean Architecture** principles. The app displays characters from the Rick and Morty API with features including infinite scroll pagination, status filtering, and detailed character views.

### Technology Stack
- **Language**: Swift 6.0 (strict concurrency enabled)
- **UI Framework**: SwiftUI with `@Observable` macro
- **Minimum Deployment**: iOS 17.0+
- **Build System**: Xcode 16.4+
- **Dependency Management**: Swift Package Manager (SPM)
- **Architecture**: Clean Architecture with modular design
- **Routing**: SUIRouting (v1.0.7)
- **Testing**: Swift Testing Framework

---

## Architectural Principles

### 1. Clean Architecture
The application strictly follows Clean Architecture, separating concerns into distinct layers with clear dependency directions.

**Dependency Rule**: Dependencies point inward. Outer layers depend on inner layers, never the reverse.

```
┌─────────────────────────────────────────────┐
│   Presentation Layer (Views & ViewModels)  │
│   (FeedView, CharacterDetailsView, etc.)   │
└──────────────────┬──────────────────────────┘
                   │ depends on
                   ↓
┌─────────────────────────────────────────────┐
│      Business Logic Layer (Use Cases)       │
│         (FeedUseCase, protocols)            │
└──────────────────┬──────────────────────────┘
                   │ depends on
                   ↓
┌─────────────────────────────────────────────┐
│          Data Layer (Repository)            │
│  (RickMortyRepository, RickMortyNetworkLayer)│
└─────────────────────────────────────────────┘
```

### 2. Protocol-Oriented Design
All inter-layer communication happens through protocols, enabling:
- Testability (easy mocking)
- Flexibility (swap implementations)
- Decoupling (layers don't know concrete types)

**Key Protocols**:
- `NetworkService` - HTTP client abstraction
- `FeedRepositoryProtocol` - Data access abstraction
- `FeedUseCaseProtocol` - Business logic abstraction
- Router protocols - Navigation abstraction

### 3. Dependency Injection
All dependencies are:
- Registered in `AppComposition.swift`
- Resolved through `DIContainer`
- Injected via constructors (never accessed globally)

### 4. Unidirectional Data Flow
Data flows in one direction:
```
User Action → ViewModel → UseCase → Repository → NetworkService
                ↓             ↓          ↓            ↓
             Update       Business    Data        HTTP
              State        Logic     Access      Request
```

### 5. Actor Isolation
- Most classes are `@MainActor` to ensure UI updates on main thread
- Critical for preventing data races in Swift 6's strict concurrency model
- **Do not remove `@MainActor` without careful consideration**

---

## Layer Structure

### Presentation Layer
**Responsibility**: UI rendering, user interaction, view state management

**Components**:
- SwiftUI Views (`FeedView`, `CharacterDetailsView`, `TabBarView`)
- ViewModels (manage view state, coordinate with use cases)
- Builders (compose views with dependencies)
- Routers (handle navigation)
- UI Components (`RickMortyUI` package)

**Rules**:
- Views are stateless and declarative
- ViewModels hold state and handle business logic coordination
- No direct network or repository access
- Communicate only with use cases

### Business Logic Layer
**Responsibility**: Application-specific business rules, data transformation

**Components**:
- Use Cases (`FeedUseCase`)
- Domain Models (`CharacterResponse`, `CharactersPageResponse`)
- Adapters (map DTOs to ViewModels)
- Business Logic Protocols

**Rules**:
- No UI dependencies (no SwiftUI imports)
- No knowledge of data sources
- Pure business logic only
- Framework-independent

### Data Layer
**Responsibility**: Data access, external service communication

**Components**:
- Repositories (`RickMortyRepository`)
- Network Layer (`RickMortyNetworkLayer`)
- API Definitions (`CoreAPI`)
- DTOs (Data Transfer Objects)

**Rules**:
- Implements repository protocols defined in use cases
- Handles network calls, data persistence, caching
- Maps external data to domain models
- No business logic

---

## Module Breakdown

### Core Infrastructure Modules

#### 1. **RickMortyNetworkLayer**
Generic HTTP client implementation.

**Location**: Separate SPM package
**Key Types**:
- `NetworkService` (protocol)
- `URLSessionNetworkService` (implementation)
- `Endpoint` (protocol for API endpoints)

**Responsibilities**:
- HTTP request execution
- Response handling
- Error mapping
- Generic, reusable across projects

#### 2. **CoreAPI**
API endpoint definitions for Rick and Morty API.

**Location**: Separate SPM package
**Key Types**:
- `RickMortyEndpoint` (enum conforming to `Endpoint`)

**Endpoints**:
```swift
enum RickMortyEndpoint: Endpoint {
    case characters(page: Int, status: String?)
    // Add more as needed

    var baseURL: String { "https://rickandmortyapi.com/api" }
}
```

#### 3. **RickMortyRepository**
Data access orchestration.

**Location**: Separate SPM package
**Key Types**:
- `FeedRepository` (implements `FeedRepositoryProtocol`)

**Responsibilities**:
- Coordinate network calls
- Map DTOs to domain models
- Handle data layer errors

#### 4. **DependencyContainer**
Simple service locator.

**Location**: Separate SPM package
**Key Methods**:
```swift
func register<T>(_ type: T.Type, _ instance: T)
func requireResolve<T>(_ type: T.Type) throws -> T
```

**Attributes**:
- `@MainActor` isolated
- `@Observable` for SwiftUI integration

### Business Logic Modules

#### 5. **UseCase**
Business logic and domain models.

**Location**: Separate SPM package
**Key Types**:
- `FeedUseCase` (implements `FeedUseCaseProtocol`)
- Domain models: `CharacterResponse`, `CharactersPageResponse`
- Adapters: `CharacterAdapter` (maps domain → ViewModel)

**Responsibilities**:
- Paginated character fetching
- Status filtering logic
- Error handling and mapping
- Data transformation

### Presentation Modules

#### 6. **FeedView**
Character list feature.

**Location**: Separate SPM package
**Key Types**:
- `FeedView` (SwiftUI view)
- `FeedViewModel` (state machine pattern)
- `FeedBuilder` (dependency composition)

**Features**:
- Infinite scroll pagination
- Pull-to-refresh
- Status filtering (Alive, Dead, Unknown)
- Error handling with retry

**State Machine**:
```swift
enum State {
    case idle
    case loading
    case loaded([CharacterAdapter])
    case error(FeedError)
    case loadingMore([CharacterAdapter])
}
```

#### 7. **CharacterDetailsView**
Character detail screen.

**Location**: Separate SPM package
**Pattern**: Similar to FeedView (Builder + ViewModel + View)

#### 8. **TabBarView**
Main tab navigation.

**Location**: Separate SPM package
**Uses**: SUIRouting for tab coordination

#### 9. **RickMortyUI**
Shared UI components.

**Location**: Separate SPM package
**Components**:
- `CharacterView` - Character card
- `ErrorView` - Error display with retry
- `FiltersView` - Filter UI
- `CharacterTableViewCell` - Legacy UIKit cell (if needed)

### Utility Modules

#### 10. **DevPreview**
SwiftUI preview support with real dependencies.

**Location**: Separate SPM package
**Usage**:
```swift
#Preview {
    let builder = FeedBuilder(container: DevPreview.shared.container)
    return builder.buildFeedView(router: previewRouter)
}
```

---

## Dependency Management

### Registration Flow
Dependencies are registered in `AppComposition.swift` in a specific order:

```swift
// 1. Infrastructure
container.register(NetworkService.self, URLSessionNetworkService(session: .shared))

// 2. Resolve infrastructure for data layer
let networkService = try container.requireResolve(NetworkService.self)

// 3. Data layer
container.register(
    FeedRepositoryProtocol.self,
    FeedRepository(networkService: networkService)
)

// 4. Business logic layer
container.register(
    FeedUseCaseProtocol.self,
    FeedUseCase(container: container)
)

// 5. Presentation layer (via builders)
let feedBuilder = FeedBuilder(container: container)
```

### Resolution Rules
1. **Registration order matters** - Register dependencies before dependents
2. **Use `requireResolve()`** - Throws error if dependency missing
3. **No force unwrapping** - Always handle resolution errors
4. **Constructor injection only** - No property injection

---

## Data Flow

### Example: Loading Characters with Filter

```
1. User Action
   ↓
   FeedView (tap filter button)

2. View → ViewModel
   ↓
   FeedViewModel.filterCharacters(status: "alive")

3. ViewModel → UseCase
   ↓
   FeedUseCase.fetchCharacters(page: 1, status: "alive")

4. UseCase → Repository
   ↓
   FeedRepository.getCharacters(page: 1, status: "alive")

5. Repository → Network
   ↓
   NetworkService.request(endpoint: .characters(page: 1, status: "alive"))

6. Network Response
   ↓
   Repository maps DTO → Domain Model

7. UseCase Transformation
   ↓
   CharacterAdapter.from(domainModel)

8. ViewModel State Update
   ↓
   state = .loaded([CharacterAdapter])

9. View Re-renders
   ↓
   FeedView displays updated list
```

---

## Design Patterns

### 1. Builder Pattern
Every feature has a Builder class that composes views with dependencies.

**Purpose**:
- Centralize dependency injection
- Keep views testable
- Decouple view creation from DI container

**Example**:
```swift
@MainActor
@Observable
final class FeedBuilder {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func buildFeedView(router: FeedRouterProtocol) -> FeedView {
        let useCase = try! container.requireResolve(FeedUseCaseProtocol.self)
        let viewModel = FeedViewModel(useCase: useCase, router: router)
        return FeedView(viewModel: viewModel)
    }
}
```

### 2. State Machine Pattern
ViewModels use enum-based state machines for clarity.

**Benefits**:
- Impossible states become impossible
- Clear state transitions
- Easy to test

**Example**:
```swift
enum State {
    case idle
    case loading
    case loaded([CharacterAdapter])
    case error(FeedError)
    case loadingMore([CharacterAdapter])
}

func loadCharacters() {
    state = .loading
    Task {
        do {
            let characters = try await useCase.fetchCharacters(page: 1)
            state = .loaded(characters)
        } catch {
            state = .error(mapError(error))
        }
    }
}
```

### 3. Repository Pattern
Abstracts data sources behind protocols.

**Benefits**:
- Swap implementations (network, cache, mock)
- Testability
- Single source of truth for data access

### 4. Adapter Pattern
Transforms data between layers.

**Purpose**:
- Keep layers independent
- Map external models to internal models
- Add computed properties for views

**Example**:
```swift
struct CharacterAdapter {
    let id: Int
    let name: String
    let imageURL: String
    let status: String

    static func from(_ domain: CharacterResponse) -> CharacterAdapter {
        CharacterAdapter(
            id: domain.id,
            name: domain.name,
            imageURL: domain.image,
            status: domain.status
        )
    }
}
```

### 5. Protocol-Oriented Programming
All abstractions are protocols, not base classes.

**Benefits**:
- Better testability
- Composition over inheritance
- Value semantics when possible

---

## Navigation

### SUIRouting Library
The app uses the external **SUIRouting** library (v1.0.7) for declarative navigation.

**Pattern**:
```swift
protocol FeedRouterProtocol {
    func navigateToDetails(character: CharacterAdapter)
}

final class FeedRouter: FeedRouterProtocol {
    private let router: Router // SUIRouting

    func navigateToDetails(character: CharacterAdapter) {
        router.push(CharacterDetailsView(character: character))
    }
}
```

**Key Concepts**:
- Routers are protocol-based
- Injected into ViewModels
- Use `Router` object from SUIRouting for actual navigation

---

## State Management

### SwiftUI @Observable
The app uses Swift 5.9+ `@Observable` macro instead of `ObservableObject`.

**Usage**:
```swift
@MainActor
@Observable
final class FeedViewModel {
    var state: State = .idle
    var isLoading: Bool { /* computed */ }

    // SwiftUI tracks changes automatically
}
```

**Benefits**:
- Less boilerplate
- Automatic change tracking
- Better performance

### State Machine Pattern
ViewModels manage state transitions explicitly:

```swift
// Initial state
state = .idle

// Loading first page
state = .loading

// Loaded successfully
state = .loaded(characters)

// Loading more pages
state = .loadingMore(existingCharacters)

// Error occurred
state = .error(feedError)
```

---

## Testing Strategy

### Unit Tests
Each SPM package has its own `Tests/` directory.

**Framework**: Swift Testing (modern, built-in)

**Test Structure**:
```
Package/
├── Sources/
│   └── FeatureName/
└── Tests/
    └── FeatureNameTests/
```

### Test Doubles

#### Protocol-Based Mocks
```swift
final class MockNetworkService: NetworkService {
    var stubbedResult: Result<Data, Error>?

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        // Return stubbed data
    }
}
```

#### Fake Use Cases
```swift
final class FakeFeedUseCase: FeedUseCaseProtocol {
    var characters: [CharacterAdapter] = []

    func fetchCharacters(page: Int, status: String?) async throws -> [CharacterAdapter] {
        return characters
    }
}
```

### Testing ViewModels
Test state transitions and business logic:

```swift
@Test
func testLoadCharactersSuccess() async {
    let fakeUseCase = FakeFeedUseCase()
    let viewModel = FeedViewModel(useCase: fakeUseCase, router: mockRouter)

    await viewModel.loadCharacters()

    #expect(viewModel.state == .loaded(fakeUseCase.characters))
}
```

### Testing Repositories
Mock `NetworkService` to test in isolation:

```swift
@Test
func testRepositoryFetchCharacters() async throws {
    let mockNetwork = MockNetworkService()
    let repository = FeedRepository(networkService: mockNetwork)

    let result = try await repository.getCharacters(page: 1)

    #expect(result.count > 0)
}
```

---

## Common Patterns

### 1. Pagination Implementation

**Guard Against Concurrent Requests**:
```swift
private var isLoading = false

func loadMore() {
    guard !isLoading else { return }
    isLoading = true
    defer { isLoading = false }

    // Load next page
}
```

**State Transitions**:
```swift
// First page
currentPage = 1
state = .loading

// Subsequent pages
currentPage += 1
state = .loadingMore(existingCharacters)
```

**Reset on Filter**:
```swift
func filterCharacters(status: String?) {
    currentPage = 1
    characters.removeAll()
    loadCharacters()
}
```

### 2. Error Mapping

**Repository → UseCase**:
```swift
do {
    return try await networkService.request(endpoint: endpoint)
} catch let error as URLError {
    throw FeedError.network(error)
} catch let error as DecodingError {
    throw FeedError.decoding(error)
} catch {
    throw FeedError.unknown(error.localizedDescription)
}
```

**UseCase → ViewModel**:
```swift
catch {
    if let feedError = error as? FeedError {
        state = .error(feedError)
    } else {
        state = .error(.unknown(error.localizedDescription))
    }
}
```

**ViewModel → View**:
```swift
var errorMessage: String {
    switch state {
    case .error(let feedError):
        switch feedError {
        case .network: return "Network error. Please check your connection."
        case .decoding: return "Unable to parse response."
        case .server(let status): return "Server error: \(status)"
        case .unknown(let msg): return msg
        }
    default: return ""
    }
}
```

### 3. SwiftUI Previews with DevPreview

```swift
#Preview("Feed - Loaded") {
    let container = DevPreview.shared.container
    let builder = FeedBuilder(container: container)
    let router = PreviewFeedRouter()
    return builder.buildFeedView(router: router)
}
```

### 4. Adding New Endpoints

**Step 1**: Add to `RickMortyEndpoint`:
```swift
enum RickMortyEndpoint: Endpoint {
    case characters(page: Int, status: String?)
    case character(id: Int) // New endpoint

    var path: String {
        switch self {
        case .characters: return "/character"
        case .character(let id): return "/character/\(id)"
        }
    }
}
```

**Step 2**: Add repository method:
```swift
protocol FeedRepositoryProtocol {
    func getCharacter(id: Int) async throws -> CharacterResponse
}
```

**Step 3**: Implement in repository:
```swift
func getCharacter(id: Int) async throws -> CharacterResponse {
    return try await networkService.request(
        endpoint: RickMortyEndpoint.character(id: id)
    )
}
```

**Step 4**: Expose in use case:
```swift
func fetchCharacter(id: Int) async throws -> CharacterAdapter {
    let character = try await repository.getCharacter(id: id)
    return CharacterAdapter.from(character)
}
```

### 5. Adding New Features

**Step 1**: Create SPM package:
```bash
# In workspace root
mkdir -p NewFeature/Sources/NewFeature
mkdir -p NewFeature/Tests/NewFeatureTests
# Create Package.swift
```

**Step 2**: Add to workspace:
- File → Add Package → Add Local...
- Select `NewFeature` directory

**Step 3**: Create Builder:
```swift
@MainActor
@Observable
final class NewFeatureBuilder {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func buildView(router: NewFeatureRouterProtocol) -> NewFeatureView {
        // Resolve dependencies and create view
    }
}
```

**Step 4**: Register in `AppComposition`:
```swift
// Register any new use cases/repositories
container.register(NewFeatureUseCaseProtocol.self, NewFeatureUseCase(...))
```

---

## Important Constraints

### 1. Always Use Workspace
- **Open**: `RickMorty.xcworkspace`
- **Never open**: `RickMorty.xcodeproj`
- Workspace manages multiple SPM packages

### 2. @MainActor is Critical
- Most classes are `@MainActor` for thread safety
- Removing can cause data races in Swift 6
- Only remove with careful consideration and testing

### 3. No Force Unwrapping
- Use safe unwrapping: `if let`, `guard let`
- Use `requireResolve()` for DI (throws on failure)
- Handle all optionals gracefully

### 4. Protocol-First Development
- Always define protocols for cross-module dependencies
- Concrete types are implementation details
- Enables testing and flexibility

### 5. Builder Pattern is Mandatory
- Features composed via builder classes
- Never instantiate feature views directly
- Builders encapsulate dependency injection

### 6. External Dependencies
- **SUIRouting**: Pinned at v1.0.7
- Navigation library for declarative routing
- Do not update without testing

---

## API Reference

### Rick and Morty API

**Base URL**: `https://rickandmortyapi.com/api`

**Authentication**: None required

**Response Format**: JSON

#### Endpoints

##### Get Characters (Paginated)
```
GET /character
Query Parameters:
  - page: Int (1-based, default: 1)
  - status: String? (alive, dead, unknown)

Response:
{
  "info": {
    "count": 826,
    "pages": 42,
    "next": "https://...",
    "prev": null
  },
  "results": [
    {
      "id": 1,
      "name": "Rick Sanchez",
      "status": "Alive",
      "species": "Human",
      "type": "",
      "gender": "Male",
      "origin": { "name": "Earth", "url": "..." },
      "location": { "name": "Earth", "url": "..." },
      "image": "https://...",
      "episode": ["..."],
      "url": "https://...",
      "created": "2017-11-04T18:48:46.250Z"
    }
  ]
}
```

---

## Best Practices Summary

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Injection**: All dependencies injected via constructors
3. **Protocol Abstraction**: Communicate through interfaces, not concrete types
4. **Unidirectional Flow**: Data flows outer → inner layers only
5. **State Machines**: Use enums for view state management
6. **Thread Safety**: Use `@MainActor` for UI-related code
7. **Error Handling**: Map errors at each layer boundary
8. **Testing**: Write unit tests with protocol-based mocks
9. **Modular Design**: Each feature is an independent SPM package
10. **Builder Pattern**: Compose features via builder classes

---

## Conclusion

This architecture ensures:
- **Scalability**: Easy to add new features without affecting existing code
- **Testability**: Protocol-oriented design enables easy mocking
- **Maintainability**: Clear separation of concerns and consistent patterns
- **Type Safety**: Leverages Swift's type system and strict concurrency
- **Readability**: Predictable structure and naming conventions

By following these principles and patterns, the codebase remains clean, testable, and production-ready.
