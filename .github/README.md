[![CI](https://github.com/obadasemary/Rick-Morty/actions/workflows/coverage.yml/badge.svg)](https://github.com/obadasemary/Rick-Morty/actions/workflows/coverage.yml)
[![Swift](https://img.shields.io/badge/Swift-5.9--6.2-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.6--26.2-blue.svg)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0--26.2-blue.svg)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

# GitHub Actions CI/CD Pipeline

This repository uses GitHub Actions for continuous integration and deployment. The CI pipeline ensures code quality, runs comprehensive tests, and validates builds across different components.

## Workflow Overview

### Main CI Pipeline (`.github/workflows/ci.yml`)

The CI pipeline runs on:
- **Push** to `main` or `develop` branches
- **Pull Requests** targeting `main` or `develop` branches

## Jobs and Components

### 1. **xcode-build-test**
- **Purpose**: Build and test the main iOS app
- **Platform**: macOS latest
- **Actions**:
  - Cache DerivedData for faster builds
  - Build and test the main RickMorty workspace
  - Uses iPhone 16 simulator with latest iOS

### 2. **spm-packages-test**
- **Purpose**: Test individual Swift Package Manager packages
- **Packages Tested**:
  - `RickMortyRepository` - Repository layer with network abstraction
  - `DependencyContainer` - Dependency injection container
  - `UseCase` - Business logic layer
  - `CoreAPI` - API endpoints and DTOs
  - `RickMortyNetworkLayer` - Low-level HTTP client
- **Strategy**: Matrix build for parallel testing
- **Actions**: Run `swift test` for each package

### 3. **feedview-test**
- **Purpose**: Test FeedView package with platform compatibility handling
- **Special Handling**: 
  - Checks for SUIRouting platform compatibility issues
  - Gracefully skips if macOS version conflicts exist
  - Provides detailed error information

### 4. **ui-tests**
- **Purpose**: Run UI tests for the main app
- **Actions**:
  - Cache DerivedData
  - Run RickMortyUITests on iPhone 16 simulator
  - Validates user interface functionality

### 5. **code-quality**
- **Purpose**: Validate code quality and dependencies
- **Actions**:
  - Check Swift Package Manager dependencies
  - Validate Package.swift files
  - Ensure proper dependency resolution

### 6. **build-verification**
- **Purpose**: Verify that all packages can build successfully
- **Strategy**: Matrix build for parallel verification
- **Actions**: Run `swift build` for each package

### 7. **integration-test**
- **Purpose**: End-to-end integration testing
- **Dependencies**: Requires `spm-packages-test` and `build-verification` to pass
- **Actions**: Build the complete app with all packages integrated

## Platform Support

### iOS
- **Minimum Version**: iOS 17.0
- **Simulator**: iPhone 16 with latest iOS
- **Testing**: Full app build and UI tests

### macOS
- **Minimum Version**: macOS 14.0 (for packages using @Observable)
- **Compatibility**: Ensures @Observable framework works correctly
- **Testing**: Swift Package Manager tests

## Architecture Compliance

The CI pipeline validates:

### Clean Architecture
- ✅ **Repository Layer** (`RickMortyRepository`)
- ✅ **Use Case Layer** (`UseCase`)
- ✅ **Network Layer** (`RickMortyNetworkLayer`)
- ✅ **API Layer** (`CoreAPI`)
- ✅ **Dependency Injection** (`DependencyContainer`)

### Swift Concurrency
- ✅ **@MainActor** isolation
- ✅ **@Observable** framework usage
- ✅ **async/await** patterns
- ✅ **Sendable** conformance

### Testing Strategy
- ✅ **Unit Tests** for all business logic
- ✅ **Integration Tests** for package interactions
- ✅ **UI Tests** for user interface
- ✅ **Build Verification** for compilation

## Environment Variables

```yaml
NSUnbufferedIO: "YES"           # Better logging output
IOS_SIMULATOR_OS: "18.6"        # iOS simulator version
```

## Caching Strategy

- **DerivedData**: Cached for faster Xcode builds
- **SPM Dependencies**: Resolved and cached per package
- **Build Artifacts**: Cached between workflow runs

## Error Handling

### Platform Compatibility
- **SUIRouting Issues**: Gracefully handled with detailed error messages
- **macOS Version Conflicts**: Clear documentation of requirements
- **Dependency Conflicts**: Validated during build verification

### Test Failures
- **Unit Test Failures**: Detailed error reporting per package
- **Build Failures**: Comprehensive build logs
- **UI Test Failures**: Screenshot capture and detailed logs

## Local Development

### Running Tests Locally

```bash
# Test individual packages
cd RickMortyRepository && swift test
cd DependencyContainer && swift test
cd UseCase && swift test
cd CoreAPI && swift test
cd RickMortyNetworkLayer && swift test

# Test main app
xcodebuild -workspace RickMorty.xcworkspace -scheme RickMorty -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' test

# Run UI tests
xcodebuild -workspace RickMorty.xcworkspace -scheme RickMorty -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -only-testing:RickMortyUITests test
```

### Build Verification

```bash
# Build all packages
for package in RickMortyRepository DependencyContainer UseCase CoreAPI RickMortyNetworkLayer; do
  cd "$package" && swift build && cd ..
done

# Build main app
xcodebuild -workspace RickMorty.xcworkspace -scheme RickMorty -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build
```

## Troubleshooting

### Common Issues

1. **SUIRouting Platform Conflicts**
   - **Cause**: SUIRouting requires newer macOS versions
   - **Solution**: CI gracefully skips with detailed error message

2. **@Observable Framework Issues**
   - **Cause**: macOS version mismatch
   - **Solution**: Ensure macOS 14.0+ support in Package.swift

3. **Dependency Resolution Failures**
   - **Cause**: Package.swift configuration issues
   - **Solution**: Check dependency versions and platform requirements

### Debug Commands

```bash
# Check Swift version
swift --version

# Check Xcode version
xcodebuild -version

# Resolve dependencies
swift package resolve

# Show package dependencies
swift package show-dependencies

# Describe package
swift package describe
```

## Performance Optimization

- **Parallel Testing**: Matrix builds for faster execution
- **Caching**: DerivedData and dependency caching
- **Conditional Execution**: Skip problematic tests with clear messaging
- **Efficient Builds**: Use latest simulators and optimized build settings

This CI pipeline ensures robust testing, quality assurance, and reliable builds for the RickMorty iOS application with Clean Architecture principles.
