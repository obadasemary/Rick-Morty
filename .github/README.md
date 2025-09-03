# 🚀 CI/CD Pipeline Documentation

This directory contains GitHub Actions workflows for the RickMorty iOS app, providing comprehensive automation for building, testing, and deploying the application.

## 📋 Workflows Overview

### 1. **CI Pipeline** (`ci.yml`)
**Triggers**: Push to main branches, Pull Requests
**Purpose**: Continuous Integration with comprehensive quality checks

#### Jobs:
- **Code Quality & Linting**: SwiftLint, TODO/FIXME checks
- **Build & Unit Tests**: Multi-scheme building and unit testing
- **Swift Package Tests**: Individual package testing with coverage
- **UI Tests**: Comprehensive UI automation testing
- **Build Configurations**: Debug/Release builds for multiple devices
- **Security Check**: Vulnerability scanning and dependency validation
- **Performance Analysis**: App size and performance metrics
- **Documentation Check**: README and documentation validation

### 2. **Release Pipeline** (`release.yml`)
**Triggers**: Version tags, Manual dispatch
**Purpose**: Automated release creation and deployment

#### Jobs:
- **Create Release**: Generate release notes and GitHub release
- **Build Release**: Archive and export IPA for distribution
- **Test Release**: Full test suite validation
- **Security Scan**: Release-specific security checks
- **Performance Benchmark**: Release performance validation
- **Update Release**: Final release status update

### 3. **Dependencies & Security** (`dependencies.yml`)
**Triggers**: Weekly schedule, Package changes, Manual dispatch
**Purpose**: Dependency management and security monitoring

#### Jobs:
- **Check Updates**: Swift Package dependency updates
- **Security Scan**: Vulnerability and security pattern detection
- **License Check**: License compliance validation
- **Health Check**: Package health and circular dependency detection
- **Security Report**: Comprehensive security status report
- **Notify**: Alert on security issues

### 4. **Code Coverage & Quality** (`coverage.yml`)
**Triggers**: Push to main branches, PRs, Weekly schedule
**Purpose**: Code quality metrics and coverage analysis

#### Jobs:
- **Code Coverage**: Main app coverage generation
- **Package Coverage**: Individual package coverage analysis
- **Quality Metrics**: SwiftLint, complexity, and code metrics
- **Performance Metrics**: Launch time and performance testing
- **Coverage Summary**: Comprehensive coverage reporting

## 🛠️ Configuration

### Environment Variables
```yaml
DEVELOPER_DIR: /Applications/Xcode_16.4.app/Contents/Developer
IOS_SIMULATOR_DEVICE: "iPhone 16"
IOS_SIMULATOR_OS: "18.5"
```

### Required Secrets
- `GITHUB_TOKEN`: Automatically provided by GitHub
- `CODECOV_TOKEN`: For coverage reporting (optional)

### Cache Configuration
- **Swift Package Manager**: Cached based on `Package.resolved`
- **DerivedData**: Cached for faster builds
- **Build artifacts**: 30-day retention

## 📊 Quality Gates

### Build Requirements
- ✅ All Swift packages must build successfully
- ✅ Unit tests must pass with >80% coverage
- ✅ UI tests must pass for critical user flows
- ✅ No SwiftLint errors or warnings
- ✅ No security vulnerabilities detected

### Release Requirements
- ✅ Full test suite passes
- ✅ Security scan clean
- ✅ Performance benchmarks met
- ✅ Documentation up to date
- ✅ License compliance verified

## 🎯 Usage

### Running CI Pipeline
```bash
# Triggered automatically on:
git push origin main
git push origin develop
git push origin Enhancement
git push origin UITests

# Or create a Pull Request
gh pr create --title "Feature: New functionality"
```

### Creating a Release
```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0

# Or trigger manually via GitHub Actions UI
```

### Manual Workflow Dispatch
```bash
# Trigger any workflow manually via GitHub Actions UI
# Useful for testing or emergency releases
```

## 📈 Metrics & Reporting

### Coverage Reports
- **Codecov Integration**: Automatic coverage reporting
- **Package Coverage**: Individual package metrics
- **Coverage Trends**: Historical coverage tracking

### Quality Metrics
- **SwiftLint Reports**: Code quality analysis
- **Performance Metrics**: Launch time and app size
- **Security Reports**: Vulnerability and compliance status

### Artifacts
- **Test Results**: `.xcresult` files for detailed analysis
- **Coverage Reports**: JSON and HTML coverage reports
- **Build Artifacts**: IPA files and archives
- **Quality Reports**: SwiftLint and security analysis

## 🔧 Customization

### Adding New Tests
1. Add test files to appropriate packages
2. Update workflow to include new test targets
3. Configure coverage collection if needed

### Modifying Quality Gates
1. Edit workflow files to adjust thresholds
2. Update SwiftLint configuration
3. Modify security scan patterns

### Adding New Platforms
1. Update destination configurations
2. Add new simulator devices
3. Configure platform-specific tests

## 🚨 Troubleshooting

### Common Issues
- **Build Failures**: Check Xcode version compatibility
- **Test Failures**: Verify simulator availability
- **Coverage Issues**: Ensure proper test configuration
- **Security Alerts**: Review and address flagged patterns

### Debugging
- Check workflow logs in GitHub Actions
- Download artifacts for detailed analysis
- Review test results and coverage reports
- Monitor performance metrics trends

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Swift Package Manager](https://swift.org/package-manager/)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)

## 🤝 Contributing

When adding new workflows or modifying existing ones:

1. **Test Locally**: Use `act` to test workflows locally
2. **Document Changes**: Update this README
3. **Review Security**: Ensure no secrets are exposed
4. **Performance**: Optimize for build time and resource usage
5. **Monitoring**: Add appropriate notifications and alerts

---

**Last Updated**: September 2025  
**Maintainer**: RickMorty Development Team
