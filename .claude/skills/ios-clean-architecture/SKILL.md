---
name: ios-clean-architecture
description: Use when working on iOS/SwiftUI projects that follow Clean Architecture with SPM modules, a DIContainer, Builder pattern, and UseCase/Repository/NetworkService layers. Triggers on creating a new feature module, adding a network endpoint, wiring a ViewModel state machine, setting up dependency injection, or reviewing layer boundaries. Swift 6.2 / iOS 17+ / SwiftUI + @Observable.
---

# iOS Clean Architecture (SwiftUI + SPM, Swift 6.2)

Modular Clean Architecture template for iOS apps. Protocol-first, DI via a
service-locator container, Builder pattern per feature, `@Observable`
ViewModels with enum state machines. Targets **Swift 6.2**, which makes
**main-actor isolation the default for app code** — you no longer need
explicit `@MainActor` on most UI-adjacent types. Derived from the
Rick & Morty reference implementation.

## When to use

- iOS 17+ / **Swift 6.2** / SwiftUI project (UIKit integration OK)
- Multi-module codebase managed via Swift Package Manager
- You're creating a new feature, new endpoint, new use case, or reviewing
  layer boundaries

## Swift 6.2 default actor isolation

Enable the "approachable concurrency" defaults in each target's
`Package.swift` / build settings:

```swift
.target(
    name: "FeedView",
    swiftSettings: [
        .defaultIsolation(MainActor.self),              // Swift 6.2
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
)
```

With this on:
- Types, methods, and closures default to `@MainActor` — **do not write
  `@MainActor` by hand** on ViewModels, Builders, Repositories, UseCases,
  Routers, or the DIContainer.
- Mark code that must run off the main actor with `nonisolated` (pure
  computation, value types used across actors) or isolate it to a custom
  actor / `Task.detached`.
- Protocol conformances are inferred to the enclosing isolation, so
  `extension FeedRepository: FeedRepositoryProtocol` doesn't need any
  attribute either.

## When NOT to use

- Cross-platform (React Native, Flutter, KMP)
- UIKit-only apps that won't adopt `@Observable`
- Single-module prototypes where modularisation is overkill
- Projects using Combine + `ObservableObject` (different pattern entirely)

---

## The dependency rule

Outer layers depend on inner layers, never the reverse.

```
Presentation (Views, ViewModels, Builders, Routers)
        ↓
Business Logic (Use Cases, Domain Models, Adapters)
        ↓
Data (Repositories, Network, DTOs, Endpoints)
```

Data flows one way: **User → ViewModel → UseCase → Repository → NetworkService**.

---

## Module layout

Each concern is a separate SPM package in the workspace root.

| Package | Layer | Responsibility |
|---|---|---|
| `RickMortyNetworkLayer` | Data | Generic HTTP client (`NetworkService`, `URLSessionNetworkService`) |
| `CoreAPI` | Data | Endpoint enum implementing the `Endpoint` protocol |
| `RickMortyRepository` | Data | Implements repository protocols, orchestrates network calls |
| `DependencyContainer` | Infra | `DIContainer` service locator |
| `UseCase` | Business | Use cases, domain models, adapters, protocol definitions |
| `FeedView` / `CharacterDetailsView` / ... | Presentation | Feature modules (one package per feature) |
| `RickMortyUI` | Presentation | Shared UI components |
| `DevPreview` | Utility | `DevPreview.shared.container` for SwiftUI previews |

Open the **`.xcworkspace`**, never the `.xcodeproj` directly.

---

## Pattern templates

### 1. Endpoint protocol + enum implementation

```swift
public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var parameters: [String: Any]? { get }
    var contentType: String { get }
}

public enum RickMortyEndpoint: Endpoint {
    case getCharacters(page: Int?, status: String?)

    public var baseURL: String { "https://rickandmortyapi.com/api" }
    public var path: String {
        switch self {
        case .getCharacters: return "/character"
        }
    }
    // method, headers, parameters, contentType via switch
}
```

### 2. NetworkService

```swift
public protocol NetworkService {
    func request<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T
}
```

Concrete implementation is `URLSessionNetworkService`. **No third-party
networking libs** — use `URLSession` directly. Protocol picks up main-actor
isolation from the module's default isolation setting.

### 3. DIContainer

```swift
@Observable
public final class DIContainer {
    public func register<T>(_ service: T.Type, _ implementation: T)
    public func register<T>(_ service: T.Type, _ factory: () -> T)
    public func resolve<T>(_ service: T.Type) -> T?
    public func requireResolve<T>(_ service: T.Type) throws -> T  // throws DIError.serviceNotRegistered
}
```

Always use `requireResolve` at composition time — never force-unwrap.

### 4. Repository

```swift
@Observable
public final class FeedRepository: FeedRepositoryProtocol {
    private let networkService: NetworkService
    public init(networkService: NetworkService) { self.networkService = networkService }

    public func fetchCharacters(page: Int?, status: String?) async throws -> CharactersPageResponse {
        try await networkService.request(
            endpoint: RickMortyEndpoint.getCharacters(page: page, status: status),
            responseModel: CharactersPageResponse.self
        )
    }
}
```

Repository is a thin adapter over `NetworkService`. Protocol lives in
`UseCase` package (inner layer owns the interface).

### 5. UseCase

```swift
public protocol FeedUseCaseProtocol {
    func execute(page: Int?, status: String?) async throws -> CharactersPageResponse
}

@Observable
public final class FeedUseCase: FeedUseCaseProtocol {
    private let repository: FeedRepositoryProtocol

    public init(container: DIContainer) throws {
        self.repository = try container.requireResolve(FeedRepositoryProtocol.self)
    }

    public func execute(page: Int? = nil, status: String? = nil) async throws -> CharactersPageResponse {
        try await repository.fetchCharacters(page: page, status: status)
    }
}
```

### 6. Builder

```swift
@Observable
public final class FeedBuilder {
    private let container: DIContainer
    public init(container: DIContainer) { self.container = container }

    public func buildFeedView(router: Router) -> some View {
        let useCase = try! container.requireResolve(FeedUseCaseProtocol.self)
        let feedRouter = FeedRouter(
            router: router,
            characterDetailsBuilder: CharacterDetailsBuilder(container: container)
        )
        let viewModel = FeedViewModel(useCase: useCase, router: feedRouter)
        return FeedView(viewModel: viewModel)
    }
}
```

One Builder per feature package. It's the **only** place features are
constructed.

### 7. ViewModel (state machine + pagination)

```swift
@Observable
final class FeedViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([CharacterAdapter])
        case loadingMore([CharacterAdapter])
        case error(FeedError)
    }

    private(set) var state: State = .idle
    private(set) var characters: [CharacterAdapter] = []
    private(set) var currentPage = 1
    private(set) var hasMorePages = true
    private var isLoading = false

    private let useCase: FeedUseCaseProtocol
    private let router: FeedRouterProtocol

    init(useCase: FeedUseCaseProtocol, router: FeedRouterProtocol) {
        self.useCase = useCase
        self.router = router
    }

    func loadInitialData() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        state = .loading
        do {
            let page = try await useCase.execute(page: 1, status: nil)
            characters = page.results.map(CharacterAdapter.from)
            state = .loaded(characters)
        } catch {
            state = .error(mapError(error))
        }
    }

    func loadMoreData() async {
        guard !isLoading, hasMorePages else { return }
        isLoading = true
        defer { isLoading = false }
        state = .loadingMore(characters)
        // fetch currentPage + 1, append, update hasMorePages
    }

    func applyFilter(_ status: Status?) async {
        currentPage = 1
        characters.removeAll()
        await loadInitialData()
    }

    private func mapError(_ error: Error) -> FeedError {
        if error is URLError { return .network }
        if error is DecodingError { return .decoding }
        return .unknown(message: error.localizedDescription)
    }
}
```

**Load-bearing rules**:
- `isLoading` guard prevents concurrent fetches
- Filter/refresh always resets `currentPage = 1` and clears `characters`
- Error mapping happens at the ViewModel boundary, never deeper

### 8. Router

```swift
protocol FeedRouterProtocol {
    func showCharacterDetails(_ character: CharacterAdapter)
}

struct FeedRouter: FeedRouterProtocol {
    let router: Router  // SUIRouting
    let characterDetailsBuilder: CharacterDetailsBuilder

    func showCharacterDetails(_ character: CharacterAdapter) {
        router.showScreen(.push) { inner in
            characterDetailsBuilder.buildCharacterDetailsView(router: inner, character: character)
        }
    }
}
```

Routers are protocol-backed structs. Navigation library is **SUIRouting**
(pinned at `1.0.6+`). `router.showScreen(.push)` takes a closure receiving
an inner router for nested navigation.

### 9. AppComposition (registration order matters)

```swift
@Observable
final class AppComposition {
    let container = DIContainer()
    let feedUseCase: FeedUseCaseProtocol?
    let isConfigured: Bool

    init() {
        do {
            // 1. Infrastructure
            container.register(NetworkService.self, URLSessionNetworkService(session: .shared))
            let network = try container.requireResolve(NetworkService.self)

            // 2. Data — swap for UI testing
            if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
                container.register(FeedRepositoryProtocol.self, UITestFeedRepository())
            } else {
                container.register(FeedRepositoryProtocol.self, FeedRepository(networkService: network))
            }

            // 3. Business
            let useCase = try FeedUseCase(container: container)
            container.register(FeedUseCaseProtocol.self, useCase)

            self.feedUseCase = useCase
            self.isConfigured = true
        } catch {
            self.feedUseCase = nil
            self.isConfigured = false
        }
    }
}
```

---

## Hard constraints

1. **Swift 6.2 default actor isolation is on** — every target opts in via
   `.defaultIsolation(MainActor.self)`. Do **not** write `@MainActor` by
   hand on ViewModels, Builders, Repositories, UseCases, Routers, or the
   DIContainer; the compiler infers it. Only annotate explicitly when you
   deviate (`nonisolated`, a custom actor, `@globalActor`).
2. **Push expensive work off the main actor deliberately** — mark pure
   helpers `nonisolated`, use `Task.detached` or a dedicated actor for CPU
   work / large decoding. Default-main is a safety default, not a licence
   to block the UI.
3. **No force unwrapping** — use `requireResolve` (throws), `guard let`,
   `if let`. The one pragmatic exception is inside `Builder.build…` where
   the container is guaranteed to be configured.
4. **Protocol-first** — every cross-module dependency is a protocol.
   Concrete types never appear in another module's public API.
5. **Builder is mandatory** — features are never instantiated directly.
   Always `FeatureBuilder(container:).buildXView(router:)`.
6. **Workspace, not project** — open `*.xcworkspace`. The `.xcodeproj`
   alone doesn't see the SPM packages.
7. **`@Observable` not `ObservableObject`** — Swift 5.9+ macro, tracked
   automatically by SwiftUI. No `@Published`.
8. **Use Swift Testing**, not XCTest — `@Test`, `@Suite`.

---

## Testing patterns

```swift
@Suite("FeedViewModel • State")
struct FeedViewModelTests {

    @Test("Initial load transitions idle → loading → loaded")
    func initialLoadSuccess() async throws {
        let useCase = FakeFeedUseCase(stubbed: .success(CharactersPageResponse.fixture))
        let vm = FeedViewModel(useCase: useCase, router: SpyRouter())

        await vm.loadInitialData()

        #expect(vm.state == .loaded(useCase.stubbedCharacters))
    }
}
```

**Test doubles**:
- `MockNetworkService` — stubs `request(endpoint:responseModel:)`
- `MockURLProtocol` — for real `URLSession` tests
- `FakeFeedUseCase` — returns canned data, records calls
- `SpyRouter` — records navigation events

Each SPM package has its own `Tests/` directory. ViewModels are tested
against fake UseCases; Repositories are tested against mock
`NetworkService`.

---

## Recipes

### Add a new endpoint

1. **Endpoint** — add a case to `RickMortyEndpoint` and update `path` /
   `method` / `parameters`.
2. **Repository protocol** — add method to `FeedRepositoryProtocol` (or a
   new repo protocol) in the `UseCase` package.
3. **Repository impl** — implement in `FeedRepository` using
   `networkService.request(endpoint:responseModel:)`.
4. **UseCase** — add an `execute` method exposing the feature at the
   business-logic boundary.

### Add a new feature module

1. **Package** — `mkdir NewFeature && cd NewFeature && swift package init
   --type library`. Add to `*.xcworkspace` via Xcode → File → Add Package →
   Add Local.
2. **Builder** — `NewFeatureBuilder(container: DIContainer)` with a
   `buildXView(router:)` method. Mark `@Observable` (main-actor isolation
   is inferred).
3. **ViewModel + Router** — ViewModel is `@Observable` with enum state
   machine. Router is a protocol-backed struct. Both inherit main-actor
   isolation from the target's default.
4. **Compose** — register any new protocols in `AppComposition`. Wire the
   feature in via `TabBarBuilder` or the relevant parent builder.

### Wire up SwiftUI Previews

```swift
#Preview("Feed — loaded") {
    let container = DevPreview.shared.container
    let builder = FeedBuilder(container: container)
    RouterView { router in
        builder.buildFeedView(router: router)
    }
}
```

`DevPreview.shared.container` is pre-configured with real implementations
so previews hit the same code path as production.

---

## Anti-patterns (reject on sight)

- `ObservableObject` / `@Published` — use `@Observable` instead
- `try!` / force-unwraps outside of Builder internals
- ViewModels calling `URLSession` or repositories directly — must go
  through a UseCase
- Property injection or global singletons — constructor injection only
- Base classes for ViewModels — compose with protocols
- Concrete types crossing module boundaries — use protocols
- Updating `SUIRouting` without regression testing — pinned version,
  has known macOS quirks
- Sprinkling `@MainActor` everywhere — in Swift 6.2 with
  `defaultIsolation(MainActor.self)` it's already the default; adding it
  by hand is noise
- Dropping or weakening default isolation to silence concurrency
  warnings — fix the root cause (mark the offending code `nonisolated`
  or move it to an actor / detached task)
