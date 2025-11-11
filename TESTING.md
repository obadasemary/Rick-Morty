# Testing Guide

Comprehensive testing guide for the RickMorty iOS app. This document covers testing strategy, best practices, and detailed examples for all layers of the Clean Architecture.

## Table of Contents
1. [Testing Philosophy](#testing-philosophy)
2. [Testing Framework](#testing-framework)
3. [Test Structure](#test-structure)
4. [Testing by Layer](#testing-by-layer)
5. [Test Doubles](#test-doubles)
6. [Testing Patterns](#testing-patterns)
7. [Running Tests](#running-tests)
8. [Coverage Goals](#coverage-goals)
9. [Common Testing Scenarios](#common-testing-scenarios)
10. [Troubleshooting](#troubleshooting)

---

## Testing Philosophy

### Core Principles

1. **Test Behavior, Not Implementation**: Focus on what the code does, not how it does it
2. **Fast Tests**: Tests should run quickly to encourage frequent execution
3. **Isolated Tests**: Each test should be independent and not rely on other tests
4. **Readable Tests**: Tests should clearly communicate intent
5. **Maintainable Tests**: Tests should be easy to update as code evolves

### Testing Pyramid

```
         ┌─────────────┐
         │  UI Tests   │  (Few - Slow, Brittle)
         └─────────────┘
       ┌─────────────────┐
       │ Integration Tests│ (Some - Medium Speed)
       └─────────────────┘
     ┌───────────────────────┐
     │     Unit Tests        │ (Many - Fast, Isolated)
     └───────────────────────┘
```

**This project focuses on Unit Tests** (80%+ of testing effort)

### What to Test

#### ✅ DO Test
- Business logic (use cases)
- State management (view models)
- Data transformations (adapters)
- Error handling
- Edge cases and boundary conditions
- Repository data access logic

#### ❌ DON'T Test
- SwiftUI view rendering (test view models instead)
- External libraries (trust they're tested)
- Simple getters/setters with no logic
- Auto-generated code

---

## Testing Framework

### Swift Testing

This project uses **Swift Testing** (introduced in Swift 5.9), Apple's modern testing framework.

**Benefits over XCTest**:
- More natural Swift syntax
- Better error messages
- Parameterized tests
- Async/await support
- Macro-based test discovery

### Basic Syntax

```swift
import Testing
@testable import YourModule

@Test
func exampleTest() {
    let result = 2 + 2
    #expect(result == 4)
}

@Test
func asyncExampleTest() async throws {
    let result = try await fetchData()
    #expect(result.count > 0)
}
```

---

## Test Structure

### Directory Layout

Each SPM package has its own test directory:

```
Package/
├── Sources/
│   └── PackageName/
│       ├── ViewModel.swift
│       ├── UseCase.swift
│       └── Repository.swift
└── Tests/
    └── PackageNameTests/
        ├── ViewModelTests.swift
        ├── UseCaseTests.swift
        └── RepositoryTests.swift
```

### Test File Naming

- **Pattern**: `{ClassName}Tests.swift`
- **Examples**:
  - `FeedViewModel.swift` → `FeedViewModelTests.swift`
  - `FeedUseCase.swift` → `FeedUseCaseTests.swift`
  - `FeedRepository.swift` → `FeedRepositoryTests.swift`

### Test Function Naming

Use descriptive names that explain what is being tested:

```swift
// ✅ CORRECT: Descriptive test names
@Test func testLoadCharactersSuccessUpdatesStateToLoaded()
@Test func testLoadCharactersWithNetworkErrorUpdatesStateToError()
@Test func testFilterCharactersResetsPageToOne()
@Test func testLoadMoreAppendsToExistingCharacters()

// ❌ INCORRECT: Vague test names
@Test func testLoad()
@Test func testError()
@Test func testFilter()
```

### Test Organization

Group related tests using nested structs:

```swift
import Testing
@testable import FeedView

struct FeedViewModelTests {
    // MARK: - Loading Tests

    @Test func testInitialStateIsIdle() { }
    @Test func testLoadCharactersTransitionsToLoading() { }
    @Test func testLoadCharactersSuccessTransitionsToLoaded() { }

    // MARK: - Error Tests

    @Test func testNetworkErrorMapsToFeedError() { }
    @Test func testDecodingErrorMapsToFeedError() { }

    // MARK: - Pagination Tests

    @Test func testLoadMoreIncrementsPage() { }
    @Test func testLoadMoreAppendsCharacters() { }
}
```

---

## Testing by Layer

### 1. Testing Use Cases (Business Logic)

Use cases contain core business logic and should be thoroughly tested.

**What to Test**:
- Data transformation logic
- Business rules
- Error mapping
- Adapter conversions

**Example: FeedUseCaseTests.swift**

```swift
import Testing
@testable import UseCase

struct FeedUseCaseTests {

    @Test
    func testFetchCharactersSuccess() async throws {
        // Arrange
        let mockRepository = MockFeedRepository()
        mockRepository.stubbedCharacters = [
            CharacterResponse(id: 1, name: "Rick", status: "Alive", image: "url")
        ]
        let useCase = FeedUseCase(repository: mockRepository)

        // Act
        let result = try await useCase.fetchCharacters(page: 1, status: nil)

        // Assert
        #expect(result.count == 1)
        #expect(result[0].name == "Rick")
        #expect(mockRepository.lastRequestedPage == 1)
    }

    @Test
    func testFetchCharactersWithStatusFilter() async throws {
        // Arrange
        let mockRepository = MockFeedRepository()
        mockRepository.stubbedCharacters = [
            CharacterResponse(id: 1, name: "Rick", status: "Alive", image: "url")
        ]
        let useCase = FeedUseCase(repository: mockRepository)

        // Act
        let result = try await useCase.fetchCharacters(page: 1, status: "alive")

        // Assert
        #expect(result.count == 1)
        #expect(mockRepository.lastRequestedStatus == "alive")
    }

    @Test
    func testFetchCharactersNetworkErrorThrows() async {
        // Arrange
        let mockRepository = MockFeedRepository()
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = URLError(.notConnectedToInternet)
        let useCase = FeedUseCase(repository: mockRepository)

        // Act & Assert
        await #expect(throws: FeedError.self) {
            try await useCase.fetchCharacters(page: 1, status: nil)
        }
    }

    @Test
    func testAdapterMapsCharacterResponseCorrectly() {
        // Arrange
        let character = CharacterResponse(
            id: 1,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            image: "https://example.com/image.png"
        )

        // Act
        let adapter = CharacterAdapter.from(character)

        // Assert
        #expect(adapter.id == 1)
        #expect(adapter.name == "Rick Sanchez")
        #expect(adapter.status == "Alive")
        #expect(adapter.imageURL == "https://example.com/image.png")
    }
}
```

### 2. Testing ViewModels (State Management)

ViewModels manage UI state and coordinate with use cases. Test state transitions thoroughly.

**What to Test**:
- State transitions
- Loading states
- Error handling
- Computed properties
- User actions

**Example: FeedViewModelTests.swift**

```swift
import Testing
@testable import FeedView

@MainActor
struct FeedViewModelTests {

    @Test
    func testInitialStateIsIdle() {
        // Arrange & Act
        let viewModel = createViewModel()

        // Assert
        if case .idle = viewModel.state {
            // Success
        } else {
            Issue.record("Expected idle state")
        }
    }

    @Test
    func testLoadCharactersTransitionsToLoading() async {
        // Arrange
        let fakeUseCase = FakeFeedUseCase()
        fakeUseCase.delayResponse = true // Simulate slow network
        let viewModel = createViewModel(useCase: fakeUseCase)

        // Act
        Task {
            await viewModel.loadCharacters()
        }

        // Give time for state to update
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s

        // Assert
        if case .loading = viewModel.state {
            // Success
        } else {
            Issue.record("Expected loading state")
        }
    }

    @Test
    func testLoadCharactersSuccessUpdatesState() async throws {
        // Arrange
        let fakeUseCase = FakeFeedUseCase()
        fakeUseCase.characters = [
            CharacterAdapter(id: 1, name: "Rick", imageURL: "url", status: "Alive")
        ]
        let viewModel = createViewModel(useCase: fakeUseCase)

        // Act
        await viewModel.loadCharacters()

        // Assert
        if case .loaded(let characters) = viewModel.state {
            #expect(characters.count == 1)
            #expect(characters[0].name == "Rick")
        } else {
            Issue.record("Expected loaded state")
        }
    }

    @Test
    func testLoadCharactersErrorUpdatesState() async {
        // Arrange
        let fakeUseCase = FakeFeedUseCase()
        fakeUseCase.shouldThrowError = true
        fakeUseCase.errorToThrow = FeedError.network(URLError(.notConnectedToInternet))
        let viewModel = createViewModel(useCase: fakeUseCase)

        // Act
        await viewModel.loadCharacters()

        // Assert
        if case .error(let error) = viewModel.state {
            if case .network = error {
                // Success
            } else {
                Issue.record("Expected network error")
            }
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test
    func testIsLoadingComputedPropertyReturnsTrue() {
        // Arrange
        let viewModel = createViewModel()
        viewModel.state = .loading

        // Act & Assert
        #expect(viewModel.isLoading == true)
    }

    @Test
    func testIsLoadingComputedPropertyReturnsFalseWhenLoaded() {
        // Arrange
        let viewModel = createViewModel()
        viewModel.state = .loaded([])

        // Act & Assert
        #expect(viewModel.isLoading == false)
    }

    @Test
    func testFilterCharactersResetsPage() async {
        // Arrange
        let fakeUseCase = FakeFeedUseCase()
        let viewModel = createViewModel(useCase: fakeUseCase)
        viewModel.currentPage = 5 // Simulate being on page 5

        // Act
        await viewModel.filterCharacters(status: "alive")

        // Assert
        #expect(viewModel.currentPage == 1)
    }

    @Test
    func testLoadMoreIncrementsPage() async {
        // Arrange
        let fakeUseCase = FakeFeedUseCase()
        fakeUseCase.characters = [
            CharacterAdapter(id: 1, name: "Rick", imageURL: "url", status: "Alive")
        ]
        let viewModel = createViewModel(useCase: fakeUseCase)
        viewModel.currentPage = 1
        viewModel.state = .loaded([])

        // Act
        await viewModel.loadMore()

        // Assert
        #expect(viewModel.currentPage == 2)
    }

    @Test
    func testLoadMorePreventsConcurrentRequests() async {
        // Arrange
        let fakeUseCase = FakeFeedUseCase()
        fakeUseCase.delayResponse = true
        let viewModel = createViewModel(useCase: fakeUseCase)
        viewModel.state = .loaded([])

        // Act
        Task { await viewModel.loadMore() }
        Task { await viewModel.loadMore() } // Try to load again while loading

        // Assert
        #expect(fakeUseCase.callCount == 1) // Should only call once
    }

    // MARK: - Helper

    private func createViewModel(
        useCase: FeedUseCaseProtocol? = nil,
        router: FeedRouterProtocol? = nil
    ) -> FeedViewModel {
        let mockRouter = router ?? MockFeedRouter()
        let mockUseCase = useCase ?? FakeFeedUseCase()
        return FeedViewModel(useCase: mockUseCase, router: mockRouter)
    }
}
```

### 3. Testing Repositories (Data Access)

Repositories orchestrate data fetching and should be tested with mocked network services.

**What to Test**:
- Network calls are made with correct parameters
- Response mapping to domain models
- Error handling and propagation

**Example: FeedRepositoryTests.swift**

```swift
import Testing
@testable import RickMortyRepository

struct FeedRepositoryTests {

    @Test
    func testGetCharactersSuccess() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        let expectedResponse = CharactersPageResponse(
            info: PageInfo(count: 1, pages: 1, next: nil, prev: nil),
            results: [
                CharacterResponse(id: 1, name: "Rick", status: "Alive", image: "url")
            ]
        )
        mockNetwork.stubbedResponse = expectedResponse
        let repository = FeedRepository(networkService: mockNetwork)

        // Act
        let result = try await repository.getCharacters(page: 1, status: nil)

        // Assert
        #expect(result.count == 1)
        #expect(result[0].name == "Rick")
        #expect(mockNetwork.lastEndpoint?.path == "/character")
    }

    @Test
    func testGetCharactersWithStatusParameter() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        mockNetwork.stubbedResponse = CharactersPageResponse(info: PageInfo(), results: [])
        let repository = FeedRepository(networkService: mockNetwork)

        // Act
        _ = try await repository.getCharacters(page: 1, status: "alive")

        // Assert
        let endpoint = mockNetwork.lastEndpoint as? RickMortyEndpoint
        if case .characters(let page, let status) = endpoint {
            #expect(page == 1)
            #expect(status == "alive")
        } else {
            Issue.record("Expected characters endpoint with status")
        }
    }

    @Test
    func testGetCharactersNetworkErrorPropagates() async {
        // Arrange
        let mockNetwork = MockNetworkService()
        mockNetwork.shouldThrowError = true
        mockNetwork.errorToThrow = URLError(.notConnectedToInternet)
        let repository = FeedRepository(networkService: mockNetwork)

        // Act & Assert
        await #expect(throws: URLError.self) {
            try await repository.getCharacters(page: 1, status: nil)
        }
    }
}
```

### 4. Testing Network Layer

Test the network layer to ensure HTTP requests are constructed correctly.

**Example: NetworkServiceTests.swift**

```swift
import Testing
@testable import RickMortyNetworkLayer

struct NetworkServiceTests {

    @Test
    func testRequestBuildsCorrectURL() async throws {
        // Arrange
        let session = MockURLSession()
        let service = URLSessionNetworkService(session: session)
        let endpoint = TestEndpoint.example

        // Act
        _ = try? await service.request(endpoint: endpoint) as EmptyResponse

        // Assert
        #expect(session.lastRequest?.url?.absoluteString == "https://api.example.com/test")
    }

    @Test
    func testRequestDecodesResponseCorrectly() async throws {
        // Arrange
        let session = MockURLSession()
        let expectedData = """
        {"name": "Rick", "status": "Alive"}
        """.data(using: .utf8)!
        session.stubbedData = expectedData
        session.stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let service = URLSessionNetworkService(session: session)

        // Act
        let result: TestResponse = try await service.request(endpoint: TestEndpoint.example)

        // Assert
        #expect(result.name == "Rick")
        #expect(result.status == "Alive")
    }

    @Test
    func testRequest404ThrowsError() async {
        // Arrange
        let session = MockURLSession()
        session.stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        let service = URLSessionNetworkService(session: session)

        // Act & Assert
        await #expect(throws: NetworkError.self) {
            try await service.request(endpoint: TestEndpoint.example) as EmptyResponse
        }
    }
}
```

---

## Test Doubles

### Types of Test Doubles

1. **Mocks**: Record interactions and verify behavior
2. **Fakes**: Working implementations with shortcuts
3. **Stubs**: Provide predefined responses

### Creating Mocks

**Example: MockNetworkService**

```swift
import Foundation
@testable import RickMortyNetworkLayer

final class MockNetworkService: NetworkService {
    var shouldThrowError = false
    var errorToThrow: Error?
    var stubbedResponse: Any?
    var lastEndpoint: Endpoint?
    var callCount = 0

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        lastEndpoint = endpoint
        callCount += 1

        if shouldThrowError, let error = errorToThrow {
            throw error
        }

        guard let response = stubbedResponse as? T else {
            throw NetworkError.decodingFailed
        }

        return response
    }
}
```

**Example: MockFeedRepository**

```swift
@testable import RickMortyRepository

final class MockFeedRepository: FeedRepositoryProtocol {
    var shouldThrowError = false
    var errorToThrow: Error?
    var stubbedCharacters: [CharacterResponse] = []
    var lastRequestedPage: Int?
    var lastRequestedStatus: String?
    var callCount = 0

    func getCharacters(page: Int, status: String?) async throws -> [CharacterResponse] {
        lastRequestedPage = page
        lastRequestedStatus = status
        callCount += 1

        if shouldThrowError, let error = errorToThrow {
            throw error
        }

        return stubbedCharacters
    }
}
```

### Creating Fakes

**Example: FakeFeedUseCase**

```swift
@testable import UseCase

@MainActor
final class FakeFeedUseCase: FeedUseCaseProtocol {
    var characters: [CharacterAdapter] = []
    var shouldThrowError = false
    var errorToThrow: Error?
    var delayResponse = false
    var callCount = 0

    func fetchCharacters(page: Int, status: String?) async throws -> [CharacterAdapter] {
        callCount += 1

        if delayResponse {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }

        if shouldThrowError, let error = errorToThrow {
            throw error
        }

        return characters
    }
}
```

### Creating Stubs

**Example: StubRouter**

```swift
@testable import FeedView

final class MockFeedRouter: FeedRouterProtocol {
    var navigateToDetailsCalled = false
    var lastCharacter: CharacterAdapter?

    func navigateToDetails(character: CharacterAdapter) {
        navigateToDetailsCalled = true
        lastCharacter = character
    }
}
```

---

## Testing Patterns

### Pattern 1: Arrange-Act-Assert (AAA)

```swift
@Test
func testExample() async throws {
    // Arrange: Set up test data and dependencies
    let mockRepository = MockFeedRepository()
    mockRepository.stubbedCharacters = [/* test data */]
    let useCase = FeedUseCase(repository: mockRepository)

    // Act: Execute the code under test
    let result = try await useCase.fetchCharacters(page: 1, status: nil)

    // Assert: Verify the outcome
    #expect(result.count == 1)
    #expect(result[0].name == "Rick")
}
```

### Pattern 2: Given-When-Then (BDD Style)

```swift
@Test
func testLoadCharactersWithNetworkError() async {
    // Given a view model with a failing use case
    let fakeUseCase = FakeFeedUseCase()
    fakeUseCase.shouldThrowError = true
    fakeUseCase.errorToThrow = FeedError.network(URLError(.notConnectedToInternet))
    let viewModel = FeedViewModel(useCase: fakeUseCase, router: MockFeedRouter())

    // When loading characters
    await viewModel.loadCharacters()

    // Then the state should be error
    if case .error(let error) = viewModel.state {
        if case .network = error {
            // Test passes
        } else {
            Issue.record("Expected network error")
        }
    } else {
        Issue.record("Expected error state")
    }
}
```

### Pattern 3: Parameterized Tests

```swift
@Test(arguments: [
    ("alive", 1),
    ("dead", 2),
    ("unknown", 0),
    (nil, 3)
])
func testFilterByStatus(status: String?, expectedCount: Int) async throws {
    // Arrange
    let fakeUseCase = FakeFeedUseCase()
    fakeUseCase.characters = createCharactersForFilter(status: status, count: expectedCount)
    let viewModel = FeedViewModel(useCase: fakeUseCase, router: MockFeedRouter())

    // Act
    await viewModel.filterCharacters(status: status)

    // Assert
    if case .loaded(let characters) = viewModel.state {
        #expect(characters.count == expectedCount)
    }
}
```

### Pattern 4: Testing Async State Changes

```swift
@Test
func testLoadingStateTransition() async throws {
    // Arrange
    let fakeUseCase = FakeFeedUseCase()
    fakeUseCase.delayResponse = true
    fakeUseCase.characters = [/* test data */]
    let viewModel = FeedViewModel(useCase: fakeUseCase, router: MockFeedRouter())

    // Act - Start loading
    let loadTask = Task {
        await viewModel.loadCharacters()
    }

    // Assert - Should be loading
    try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
    #expect(viewModel.isLoading == true)

    // Wait for completion
    await loadTask.value

    // Assert - Should be loaded
    #expect(viewModel.isLoading == false)
    if case .loaded = viewModel.state {
        // Success
    } else {
        Issue.record("Expected loaded state")
    }
}
```

---

## Running Tests

### Command Line

**Run all tests**:
```bash
xcodebuild test \
  -workspace RickMorty.xcworkspace \
  -scheme RickMorty \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Run specific package tests**:
```bash
xcodebuild test \
  -workspace RickMorty.xcworkspace \
  -scheme UseCase \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Run with code coverage**:
```bash
xcodebuild test \
  -workspace RickMorty.xcworkspace \
  -scheme RickMorty \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES
```

### Xcode

**Run all tests**: `Cmd + U`

**Run single test**:
- Click diamond icon next to test function
- Or: Right-click test → Run

**Run single test suite**:
- Click diamond icon next to struct/class
- Or: Right-click test struct → Run

**View test results**:
- `Cmd + 9` (Test Navigator)
- Green checkmarks = passed
- Red X = failed

---

## Coverage Goals

### Target Coverage by Layer

- **Use Cases (Business Logic)**: 90%+
- **ViewModels (State Management)**: 85%+
- **Repositories (Data Access)**: 80%+
- **Network Layer**: 75%+
- **Overall Project**: 80%+

### Viewing Coverage

1. Run tests with coverage enabled
2. Show Report Navigator: `Cmd + 9`
3. Select Coverage tab
4. View file-by-file coverage percentages

### What Coverage Doesn't Tell You

- **Quality of tests**: 100% coverage with bad tests is worse than 80% with good tests
- **Edge cases**: May have coverage but miss important scenarios
- **Integration points**: Unit tests may not catch integration issues

---

## Common Testing Scenarios

### Scenario 1: Testing Error Messages

```swift
@Test
func testNetworkErrorMessage() {
    // Arrange
    let viewModel = FeedViewModel(useCase: FakeFeedUseCase(), router: MockFeedRouter())
    let error = FeedError.network(URLError(.notConnectedToInternet))
    viewModel.state = .error(error)

    // Act
    let message = viewModel.errorMessage

    // Assert
    #expect(message == "Network error. Please check your connection.")
}
```

### Scenario 2: Testing Computed Properties

```swift
@Test
func testCharactersComputedProperty() {
    // Arrange
    let viewModel = FeedViewModel(useCase: FakeFeedUseCase(), router: MockFeedRouter())
    let characters = [
        CharacterAdapter(id: 1, name: "Rick", imageURL: "url", status: "Alive")
    ]
    viewModel.state = .loaded(characters)

    // Act
    let result = viewModel.characters

    // Assert
    #expect(result.count == 1)
    #expect(result[0].name == "Rick")
}
```

### Scenario 3: Testing Navigation

```swift
@Test
func testSelectCharacterNavigatesToDetails() {
    // Arrange
    let mockRouter = MockFeedRouter()
    let viewModel = FeedViewModel(useCase: FakeFeedUseCase(), router: mockRouter)
    let character = CharacterAdapter(id: 1, name: "Rick", imageURL: "url", status: "Alive")

    // Act
    viewModel.selectCharacter(character)

    // Assert
    #expect(mockRouter.navigateToDetailsCalled == true)
    #expect(mockRouter.lastCharacter?.id == 1)
}
```

### Scenario 4: Testing Pagination Edge Cases

```swift
@Test
func testLoadMoreOnLastPageDoesNothing() async {
    // Arrange
    let fakeUseCase = FakeFeedUseCase()
    fakeUseCase.characters = [] // Empty response indicates last page
    let viewModel = FeedViewModel(useCase: fakeUseCase, router: MockFeedRouter())
    viewModel.currentPage = 1
    viewModel.state = .loaded([
        CharacterAdapter(id: 1, name: "Rick", imageURL: "url", status: "Alive")
    ])

    // Act
    await viewModel.loadMore()

    // Assert
    #expect(viewModel.currentPage == 1) // Should not increment
}
```

---

## Troubleshooting

### Common Issues

#### Issue: Tests hang indefinitely

**Cause**: Async test not awaiting completion

**Solution**:
```swift
// ❌ INCORRECT
@Test
func testAsync() {
    Task {
        await viewModel.load()
    }
    // Test ends before Task completes!
}

// ✅ CORRECT
@Test
func testAsync() async {
    await viewModel.load()
}
```

#### Issue: "Cannot convert value of type..." in tests

**Cause**: Missing `@testable import`

**Solution**:
```swift
import Testing
@testable import YourModule // Make internal symbols visible
```

#### Issue: Tests fail on CI but pass locally

**Cause**: Race conditions or device-specific issues

**Solution**:
- Add delays for async state changes: `try await Task.sleep(nanoseconds: 100_000_000)`
- Use consistent simulator: `iPhone 15` on latest iOS
- Check for hardcoded paths or device-specific assumptions

#### Issue: "Actor-isolated property cannot be referenced"

**Cause**: Testing `@MainActor` code without proper isolation

**Solution**:
```swift
// ✅ CORRECT
@MainActor
struct ViewModelTests {
    @Test
    func testExample() async {
        let viewModel = FeedViewModel(...)
        await viewModel.load()
    }
}
```

#### Issue: Mock not being called

**Cause**: Wrong protocol method signature or not injected

**Solution**:
- Verify protocol conformance
- Check method signature matches exactly
- Ensure mock is properly injected via constructor

---

## Best Practices Summary

1. **Write tests first**: TDD ensures testable code
2. **One assertion per test**: Makes failures easier to diagnose
3. **Use descriptive names**: Test names should explain what they test
4. **Test edge cases**: Empty arrays, nil values, boundary conditions
5. **Keep tests independent**: Tests should not depend on execution order
6. **Use test doubles**: Mock external dependencies
7. **Test behavior, not implementation**: Focus on outcomes
8. **Make tests fast**: Avoid network calls, file I/O, delays
9. **Keep tests simple**: Tests should be easier to understand than production code
10. **Update tests with code**: Tests are first-class citizens

---

## Additional Resources

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [Testing in Xcode](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
- [Clean Architecture Testing Strategies](https://blog.cleancoder.com/uncle-bob/2017/05/05/TestDefinitions.html)
- [Architecture.md](./Architecture.md) - Project architecture guide
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Contribution guidelines

---

## Conclusion

Testing is not optional. Every contribution must include tests. This guide provides the patterns and practices to write effective tests that ensure code quality, catch bugs early, and make refactoring safe.

**Remember**: Tests are your safety net. Write them well, and they'll save you hours of debugging.
