# GitHub Actions CI/CD Pipeline

This repository uses GitHub Actions for continuous integration and deployment, ensuring code quality and reliability across all platforms and packages.

## 🚀 Pipeline Overview

The CI/CD pipeline consists of multiple jobs that run in parallel to ensure comprehensive testing and validation:

### 📱 iOS App Build & Test
- **Job:** `ios-build-test`
- **Purpose:** Builds the main iOS app and runs UI tests
- **Platform:** iOS Simulator (iPhone 16, iOS 18.6)
- **Tests:** RickMortyUITests

### 📦 Swift Package Manager Tests
- **Job:** `spm-packages-test`
- **Purpose:** Tests all Swift packages individually
- **Packages Tested:**
  - ✅ FeedView
  - ✅ RickMortyRepository
  - ✅ DependencyContainer
  - ✅ UseCase
  - ✅ CoreAPI
  - ✅ RickMortyNetworkLayer
  - ✅ CharacterDetailsView
  - ✅ DevPreview
  - ✅ RickMortyUI
  - ✅ TabBarView
  - ⚠️ FeedListView (skipped due to SUIRouting compatibility issues)

### 🔍 Code Quality & Linting
- **Job:** `code-quality`
- **Purpose:** Validates Swift package dependencies and structure
- **Checks:**
  - Package dependency resolution
  - Package structure validation
  - Common Swift package issues

### 🏗️ Build Verification
- **Job:** `build-verification`
- **Purpose:** Ensures all components build successfully
- **Verifications:**
  - Main iOS app build
  - Individual package builds
  - Configuration validation

### 📊 Test Results Summary
- **Job:** `test-summary`
- **Purpose:** Provides comprehensive test results overview
- **Features:**
  - Status reporting for all jobs
  - Success/failure indicators
  - Deployment readiness check

## 🛠️ Configuration

### Environment Variables
```yaml
IOS_SIMULATOR_OS: "18.6"
IOS_SIMULATOR_NAME: "iPhone 16"
SCHEME: "RickMorty"
WORKSPACE: "RickMorty.xcworkspace"
DESTINATION: "platform=iOS Simulator,name=iPhone 16,OS=18.6"
```

### Triggers
- **Push:** `main`, `develop` branches
- **Pull Request:** `main`, `develop` branches

## 📋 Package Testing Strategy

### Tested Packages
Each Swift package is tested individually to ensure:
- ✅ Compilation success
- ✅ Unit test execution
- ✅ Dependency resolution
- ✅ Platform compatibility

### Platform Support
- **iOS:** 17.0+
- **macOS:** 14.0+ (for packages using @Observable)

### Known Issues
- **FeedListView:** Skipped due to SUIRouting dependency requiring newer macOS versions
- **SUIRouting:** Uses APIs not available on older macOS versions

## 🔧 Local Testing

### Run All Package Tests
```bash
# Test individual packages
cd RickMortyRepository && swift test
cd UseCase && swift test
cd DependencyContainer && swift test
cd CoreAPI && swift test
cd RickMortyNetworkLayer && swift test
cd FeedView && swift test
```

### Run iOS App Tests
```bash
# Build and test the main app
xcodebuild -workspace RickMorty.xcworkspace -scheme RickMorty -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' build test
```

### Run UI Tests
```bash
# Run UI tests specifically
xcodebuild test -workspace RickMorty.xcworkspace -scheme RickMorty -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' -only-testing:RickMortyUITests
```

## 📈 Performance & Caching

### DerivedData Caching
- Caches Xcode build artifacts between runs
- Significantly reduces build times
- Automatically invalidated when dependencies change

### Parallel Execution
- All package tests run in parallel
- Matrix strategy for efficient resource usage
- Independent job execution for faster feedback

## 🚨 Troubleshooting

### Common Issues

#### Package Build Failures
```bash
# Clean and rebuild
swift package clean
swift package resolve
swift build
```

#### Simulator Issues
```bash
# List available simulators
xcrun simctl list devices available

# Reset simulator
xcrun simctl erase "iPhone 16"
```

#### Dependency Resolution
```bash
# Clear package cache
swift package reset
swift package resolve
```

### CI-Specific Issues

#### Platform Compatibility
- Ensure all packages target compatible platforms
- Check @Observable usage requires macOS 14.0+
- Verify external dependencies support target platforms

#### Test Failures
- Check test data and mock implementations
- Verify network service mocking
- Ensure proper async/await usage

## 📊 Metrics & Monitoring

### Success Criteria
- ✅ All package tests pass
- ✅ Main app builds successfully
- ✅ UI tests execute without failures
- ✅ No compilation errors or warnings
- ✅ All dependencies resolve correctly

### Failure Handling
- Detailed error reporting in job logs
- Individual package failure isolation
- Clear success/failure indicators
- Comprehensive test result summary

## 🔄 Continuous Improvement

### Regular Updates
- Keep Xcode and iOS simulator versions current
- Update Swift package dependencies
- Monitor for new platform requirements
- Optimize build and test performance

### Monitoring
- Track build times and success rates
- Monitor test coverage and quality
- Review and update CI configuration
- Address platform compatibility issues

---

For questions or issues with the CI/CD pipeline, please check the GitHub Actions logs or create an issue in the repository.
