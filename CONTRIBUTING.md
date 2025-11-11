# Contributing to RickMorty iOS App

Thank you for your interest in contributing to the RickMorty iOS app! This document provides guidelines and best practices for contributing to this project.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Development Workflow](#development-workflow)
3. [Architecture Guidelines](#architecture-guidelines)
4. [Code Style](#code-style)
5. [Commit Guidelines](#commit-guidelines)
6. [Pull Request Process](#pull-request-process)
7. [Testing Requirements](#testing-requirements)
8. [Common Tasks](#common-tasks)

---

## Getting Started

### Prerequisites
- **Xcode**: 16.4 or later
- **macOS**: Latest stable version
- **Swift**: 6.0 (included with Xcode)
- **iOS Deployment Target**: 17.0+

### Initial Setup

1. **Clone the repository**:
```bash
git clone <repository-url>
cd RickMorty
```

2. **Open the workspace** (NOT the .xcodeproj):
```bash
open RickMorty.xcworkspace
```

3. **Build the project**:
```bash
xcodebuild -workspace RickMorty.xcworkspace \
  -scheme RickMorty \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

4. **Run tests** to ensure everything works:
```bash
xcodebuild test -workspace RickMorty.xcworkspace \
  -scheme RickMorty \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Development Workflow

### Branch Strategy

- **main**: Production-ready code
- **feature/**: New features (`feature/character-search`)
- **fix/**: Bug fixes (`fix/pagination-crash`)
- **refactor/**: Code improvements (`refactor/networking-layer`)
- **docs/**: Documentation updates (`docs/update-architecture`)

### Creating a New Branch

```bash
# Always branch from main
git checkout main
git pull origin main

# Create your feature branch
git checkout -b feature/your-feature-name
```

### Development Cycle

1. **Create branch** from latest `main`
2. **Make changes** following architecture guidelines
3. **Write tests** for new functionality
4. **Run tests** locally (all must pass)
5. **Commit changes** following commit guidelines
6. **Push branch** and create pull request
7. **Address review feedback**
8. **Merge** after approval

---

## Architecture Guidelines

### Core Principles

This project follows **Clean Architecture**. Before contributing, review:
- [Architecture.md](./Architecture.md) - Complete architecture documentation
- [CLAUDE.md](./CLAUDE.md) - Project overview and quick reference

### Layer Responsibilities

#### Presentation Layer
```swift
// ✅ CORRECT: View delegates to ViewModel
struct FeedView: View {
    @State private var viewModel: FeedViewModel

    var body: some View {
        List(viewModel.characters) { character in
            CharacterRow(character: character)
        }
        .onAppear { viewModel.loadCharacters() }
    }
}

// ❌ INCORRECT: View makes direct network calls
struct FeedView: View {
    func loadData() {
        URLSession.shared.dataTask(...) // NEVER DO THIS
    }
}
```

#### Business Logic Layer
```swift
// ✅ CORRECT: UseCase orchestrates business logic
final class FeedUseCase: FeedUseCaseProtocol {
    func fetchCharacters(page: Int) async throws -> [CharacterAdapter] {
        let response = try await repository.getCharacters(page: page)
        return response.map { CharacterAdapter.from($0) }
    }
}

// ❌ INCORRECT: UseCase imports SwiftUI
import SwiftUI // NEVER import UI in use cases
```

#### Data Layer
```swift
// ✅ CORRECT: Repository handles data access
final class FeedRepository: FeedRepositoryProtocol {
    private let networkService: NetworkService

    func getCharacters(page: Int) async throws -> [Character] {
        return try await networkService.request(
            endpoint: RickMortyEndpoint.characters(page: page)
        )
    }
}

// ❌ INCORRECT: Repository contains business logic
final class FeedRepository {
    func getCharacters() async throws -> [CharacterViewModel] {
        // Don't map to ViewModels in repository!
    }
}
```

### Mandatory Patterns

#### 1. Builder Pattern
Every new feature MUST use the Builder pattern:

```swift
@MainActor
@Observable
final class NewFeatureBuilder {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func buildView(router: RouterProtocol) -> NewFeatureView {
        let useCase = try! container.requireResolve(UseCaseProtocol.self)
        let viewModel = NewFeatureViewModel(useCase: useCase, router: router)
        return NewFeatureView(viewModel: viewModel)
    }
}
```

#### 2. Protocol-First Design
Always define protocols before implementations:

```swift
// 1. Define protocol in UseCase module
protocol NewFeatureUseCaseProtocol {
    func performAction() async throws -> Result
}

// 2. Implement in concrete class
final class NewFeatureUseCase: NewFeatureUseCaseProtocol {
    func performAction() async throws -> Result {
        // Implementation
    }
}

// 3. Register in AppComposition
container.register(
    NewFeatureUseCaseProtocol.self,
    NewFeatureUseCase(container: container)
)
```

#### 3. Dependency Injection
Always inject dependencies via constructor:

```swift
// ✅ CORRECT: Constructor injection
final class FeedViewModel {
    private let useCase: FeedUseCaseProtocol
    private let router: FeedRouterProtocol

    init(useCase: FeedUseCaseProtocol, router: FeedRouterProtocol) {
        self.useCase = useCase
        self.router = router
    }
}

// ❌ INCORRECT: Property injection or singletons
final class FeedViewModel {
    private let useCase = FeedUseCase.shared // NEVER
    var router: FeedRouterProtocol! // NEVER use implicitly unwrapped optionals
}
```

---

## Code Style

### Swift Style Guide

#### Naming Conventions

```swift
// Protocols
protocol FeedUseCaseProtocol { }
protocol NetworkService { }

// Classes
final class FeedUseCase { }
final class FeedViewModel { }
final class FeedBuilder { }

// Structs
struct CharacterAdapter { }
struct CharacterResponse { }

// Enums
enum State { }
enum FeedError: Error { }
enum RickMortyEndpoint: Endpoint { }

// Variables and Functions
let networkService: NetworkService
func fetchCharacters(page: Int) async throws -> [Character]
```

#### Access Control

```swift
// Use explicit access control
public protocol FeedUseCaseProtocol { }
final class FeedUseCase { } // internal by default
private let networkService: NetworkService
```

#### Concurrency Annotations

```swift
// ✅ CORRECT: Explicit actor isolation
@MainActor
@Observable
final class FeedViewModel { }

@MainActor
final class FeedBuilder { }

// ✅ CORRECT: Async/await for async operations
func loadCharacters() async throws {
    let characters = try await useCase.fetchCharacters(page: 1)
}

// ❌ INCORRECT: Removing @MainActor without justification
final class FeedViewModel { } // Data races possible!
```

#### Optional Handling

```swift
// ✅ CORRECT: Safe unwrapping
guard let character = characters.first else { return }

if let character = characters.first {
    // Use character
}

// Use nil coalescing
let name = character?.name ?? "Unknown"

// ❌ INCORRECT: Force unwrapping
let character = characters.first! // NEVER
let useCase = container.resolve(UseCase.self)! // NEVER
```

#### Error Handling

```swift
// ✅ CORRECT: Specific error types
enum FeedError: Error {
    case network(URLError)
    case decoding(DecodingError)
    case server(statusCode: Int)
    case unknown(String)
}

// Map errors at layer boundaries
do {
    let response = try await networkService.request(endpoint: endpoint)
    return response
} catch let error as URLError {
    throw FeedError.network(error)
} catch let error as DecodingError {
    throw FeedError.decoding(error)
} catch {
    throw FeedError.unknown(error.localizedDescription)
}

// ❌ INCORRECT: Generic error handling
do {
    // ...
} catch {
    print(error) // Don't just print
}
```

### SwiftUI Conventions

```swift
// ✅ CORRECT: Use @Observable (not ObservableObject)
@MainActor
@Observable
final class FeedViewModel {
    var state: State = .idle
}

// ✅ CORRECT: Computed properties for derived state
var isLoading: Bool {
    if case .loading = state { return true }
    return false
}

// ✅ CORRECT: Use @State for view-injected ViewModels
struct FeedView: View {
    @State private var viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
}
```

### Comments and Documentation

```swift
// Use documentation comments for public APIs
/// Fetches paginated characters from the Rick and Morty API.
///
/// - Parameters:
///   - page: The page number (1-based)
///   - status: Optional status filter ("alive", "dead", "unknown")
/// - Returns: Array of character adapters
/// - Throws: `FeedError` if request fails
func fetchCharacters(page: Int, status: String?) async throws -> [CharacterAdapter]

// Use inline comments for complex logic
// Reset pagination when filter changes to ensure fresh data
currentPage = 1
characters.removeAll()
```

---

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **test**: Adding or updating tests
- **docs**: Documentation changes
- **chore**: Maintenance tasks (dependencies, build config)
- **perf**: Performance improvements

### Examples

```bash
# Feature
git commit -m "feat(feed): add infinite scroll pagination to character list"

# Bug fix
git commit -m "fix(details): resolve crash when character image fails to load"

# Refactor
git commit -m "refactor(network): extract error mapping into separate utility"

# Tests
git commit -m "test(use-case): add unit tests for character filtering logic"

# Documentation
git commit -m "docs: update architecture diagram with new modules"

# With body
git commit -m "feat(feed): add status filter

Add ability to filter characters by status (alive, dead, unknown).
Implements filter UI in FiltersView and updates FeedViewModel state machine.

Closes #42"
```

### Commit Best Practices

1. **Atomic commits**: Each commit should represent one logical change
2. **Test before commit**: Ensure all tests pass
3. **No WIP commits**: Squash work-in-progress commits before PR
4. **Reference issues**: Include issue numbers in commit messages

---

## Pull Request Process

### Before Creating a PR

**Checklist**:
- [ ] All tests pass locally
- [ ] New tests added for new functionality
- [ ] Code follows architecture guidelines
- [ ] No force unwrapping or unsafe code
- [ ] Documentation updated (if needed)
- [ ] No merge conflicts with `main`
- [ ] Build succeeds on CI

### Creating a Pull Request

1. **Push your branch**:
```bash
git push origin feature/your-feature-name
```

2. **Create PR** with this template:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactoring
- [ ] Documentation update

## Changes Made
- Bullet point list of changes
- Be specific

## Testing
- [ ] Unit tests added/updated
- [ ] UI tests added/updated (if applicable)
- [ ] Manual testing completed

## Screenshots (if UI changes)
[Add screenshots here]

## Checklist
- [ ] Code follows architecture guidelines
- [ ] All tests pass
- [ ] No force unwrapping
- [ ] Documentation updated
- [ ] No breaking changes (or documented if necessary)

## Related Issues
Closes #123
```

### PR Review Process

1. **Automated checks** must pass (tests, linting)
2. **Code review** by at least one maintainer
3. **Address feedback** in new commits
4. **Squash or rebase** if requested
5. **Maintainer merges** after approval

### Review Criteria

Reviewers will check for:
- Architecture compliance
- Code quality and style
- Test coverage
- Performance implications
- Security concerns
- Documentation completeness

---

## Testing Requirements

All contributions MUST include tests. See [TESTING.md](./TESTING.md) for comprehensive testing guide.

### Minimum Requirements

**For new features**:
- Unit tests for use cases (business logic)
- Unit tests for view models (state management)
- Unit tests for repositories (data access)

**For bug fixes**:
- Test that reproduces the bug
- Test that verifies the fix

**Test Coverage Goal**: Aim for 80%+ coverage in business logic layer

### Running Tests

```bash
# All tests
xcodebuild test -workspace RickMorty.xcworkspace \
  -scheme RickMorty \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Specific package tests
xcodebuild test -workspace RickMorty.xcworkspace \
  -scheme UseCase \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Common Tasks

### Adding a New Feature Module

**Step 1**: Create SPM package structure
```bash
mkdir -p NewFeature/Sources/NewFeature
mkdir -p NewFeature/Tests/NewFeatureTests
touch NewFeature/Package.swift
```

**Step 2**: Define `Package.swift`
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NewFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "NewFeature", targets: ["NewFeature"]),
    ],
    dependencies: [
        .package(path: "../UseCase"),
        .package(path: "../DependencyContainer"),
    ],
    targets: [
        .target(
            name: "NewFeature",
            dependencies: ["UseCase", "DependencyContainer"]
        ),
        .testTarget(
            name: "NewFeatureTests",
            dependencies: ["NewFeature"]
        ),
    ]
)
```

**Step 3**: Add to workspace
- File → Add Package → Add Local...
- Select `NewFeature` directory

**Step 4**: Create Builder, ViewModel, View following existing patterns

**Step 5**: Register dependencies in `AppComposition.swift`

### Adding a New API Endpoint

**Step 1**: Update `RickMortyEndpoint` in CoreAPI
```swift
enum RickMortyEndpoint: Endpoint {
    case characters(page: Int, status: String?)
    case character(id: Int) // New

    var path: String {
        switch self {
        case .characters:
            return "/character"
        case .character(let id):
            return "/character/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .characters, .character:
            return .get
        }
    }
}
```

**Step 2**: Add repository protocol method
```swift
protocol FeedRepositoryProtocol {
    func getCharacter(id: Int) async throws -> CharacterResponse
}
```

**Step 3**: Implement in repository
```swift
func getCharacter(id: Int) async throws -> CharacterResponse {
    try await networkService.request(
        endpoint: RickMortyEndpoint.character(id: id)
    )
}
```

**Step 4**: Add use case method
```swift
protocol FeedUseCaseProtocol {
    func fetchCharacter(id: Int) async throws -> CharacterAdapter
}

func fetchCharacter(id: Int) async throws -> CharacterAdapter {
    let character = try await repository.getCharacter(id: id)
    return CharacterAdapter.from(character)
}
```

**Step 5**: Write tests for each layer

### Updating Dependencies

**External dependencies** (like SUIRouting) are managed in the main app's Package.swift.

To update:
1. Modify version in Package.swift
2. File → Packages → Update to Latest Package Versions
3. Test thoroughly (external updates can break things)
4. Document breaking changes in PR

---

## Additional Resources

- [Architecture.md](./Architecture.md) - Complete architecture guide
- [TESTING.md](./TESTING.md) - Comprehensive testing guide
- [CLAUDE.md](./CLAUDE.md) - Quick reference and build commands
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## Questions or Issues?

- **Bug reports**: Open an issue with reproduction steps
- **Feature requests**: Open an issue describing the use case
- **Questions**: Open a discussion or contact maintainers

---

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on code quality and architecture
- Help others learn and grow

Thank you for contributing to RickMorty iOS app!
