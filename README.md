# RickMorty iOS App

A modern iOS application built with SwiftUI and Clean Architecture, showcasing characters from the Rick and Morty universe. The app demonstrates best practices in iOS development including modular architecture, dependency injection, and comprehensive testing.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with a modular approach using Swift Package Manager (SPM). The architecture is organized into distinct layers with clear separation of concerns:

### Layer Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Presentation Layer                               │
│ ┌──────────┐ ┌─────────────┐ ┌──────────┐ ┌────────────────────────┐│
│ │FeedView  │ │CharacterView│ │TabBarView│ │FeedListView            ││
│ │(SwiftUI) │ │(SwiftUI)    │ │(SwiftUI) │ │(Hybrid SwiftUI + UIKit)││
│ └──────────┘ └─────────────┘ └──────────┘ └────────────────────────┘│
└─────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                UseCase                                 │ │
│  │  • FeedUseCase (Character listing, pagination)         │ │
│  │  • Error handling & mapping                            │ │
│  │  • Domain models & adapters                            │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐    │
│  │ Repository  │ │   CoreAPI   │ │  NetworkLayer       │    │
│  │ (Data orchestration) │ (Endpoints) │ (HTTP client)  │    │
│  └─────────────┘ └─────────────┘ └─────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## 📦 Package Structure

The project is organized into multiple Swift packages, each with a specific responsibility:

### Core Packages

- **`RickMortyNetworkLayer`** - Low-level HTTP client and networking infrastructure
- **`CoreAPI`** - API endpoints and request/response DTOs
- **`RickMortyRepository`** - Data orchestration layer (remote + local cache)
- **`UseCase`** - Business logic and domain models
- **`DependencyContainer`** - Dependency injection container

### Feature Packages

- **`FeedView`** - Character listing with pagination and filtering
- **`CharacterDetailsView`** - Individual character details
- **`FeedListView`** - Hybrid SwiftUI + UIKit
- **`TabBarView`** - Main app navigation structure

### Shared Packages

- **`RickMortyUI`** - Shared UI components and styling
- **`DevPreview`** - Development and preview utilities

## 🚀 Features

### Character Management
- **Character Listing**: Browse all Rick and Morty characters with infinite scroll pagination
- **Character Details**: View detailed information about each character
- **Status Filtering**: Filter characters by status (Alive, Dead, Unknown)

### Technical Features
- **Clean Architecture**: Separation of concerns with clear layer boundaries
- **Dependency Injection**: Modular and testable architecture
- **Async/Await**: Modern Swift concurrency for network operations
- **SwiftUI**: Declarative UI with reactive state management
- **Comprehensive Testing**: Unit tests for all layers with test doubles

## 🛠️ Technology Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: Clean Architecture with MVVM
- **Concurrency**: Swift Concurrency (async/await)
- **Dependency Management**: Swift Package Manager
- **Testing**: Swift Testing framework
- **Minimum iOS Version**: iOS 17.0+

## 📋 Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## 🏃‍♂️ Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd RickMorty
```

### 2. Open the Project
```bash
open RickMorty.xcworkspace
```

### 3. Build and Run
- Select your target device or simulator
- Press `Cmd + R` to build and run the app

## 🧪 Testing

The project includes comprehensive test coverage across all layers:

### Running Tests
```bash
# Run all tests
swift test

# Run tests for specific package
cd UseCase && swift test
cd FeedView && swift test
```

### Test Structure
- **Unit Tests**: Business logic, data mapping, error handling
- **Integration Tests**: Repository and network layer
- **UI Tests**: ViewModel state management and navigation

## 🏗️ Project Structure

```
RickMorty/
├── RickMorty/                    # Main iOS app target
│   ├── App/                      # App composition and entry point
│   └── Assets.xcassets/          # App assets and icons
├── CoreAPI/                      # API endpoints and DTOs
├── RickMortyNetworkLayer/        # HTTP client and networking
├── RickMortyRepository/          # Data orchestration layer
├── UseCase/                      # Business logic and domain models
├── DependencyContainer/          # Dependency injection
├── FeedView/                     # Character listing feature
├── CharacterDetailsView/         # Character details feature
├── FeedListView/                 # Hybrid SwiftUI + UIKit
├── TabBarView/                   # Main app navigation
├── RickMortyUI/                  # Shared UI components
├── DevPreview/                   # Development utilities
└── SplashView/                   # Launch screen
```

## 🔧 Configuration

### Environment Setup
The app supports different environments through the `DependencyContainer`:

- **Development**: Full API integration with real data
- **Testing**: Mock implementations for unit tests
- **Production**: Optimized for App Store deployment

### API Configuration
The app uses the [Rick and Morty API](https://rickandmortyapi.com/):
- Base URL: `https://rickandmortyapi.com/api`
- Endpoints: Character listing with pagination and filtering
- No authentication required

## 📱 App Flow

1. **Launch**: Splash screen with app branding
2. **Main Navigation**: Tab-based interface with character feeds
3. **Character Listing**: Infinite scroll with status filtering
4. **Character Details**: Detailed character information
5. **Navigation**: Seamless transitions between screens

## 🎨 UI/UX Features

- **Modern Design**: Clean, intuitive interface following iOS design guidelines
- **Responsive Layout**: Adapts to different screen sizes and orientations
- **Loading States**: Proper loading indicators and error handling
- **Accessibility**: VoiceOver support and Dynamic Type compatibility
- **Dark Mode**: Full support for iOS dark mode

## 🔍 Code Quality

### Architecture Principles
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Single Responsibility**: Each class/struct has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Interface Segregation**: Clients shouldn't depend on unused interfaces

### Code Standards
- **SwiftLint**: Code style enforcement
- **Documentation**: Comprehensive inline documentation
- **Error Handling**: Proper error propagation and user feedback
- **Memory Management**: Automatic reference counting with proper lifecycle management

## 🚀 Performance

- **Lazy Loading**: Images and data loaded on demand
- **Pagination**: Efficient memory usage with infinite scroll
- **Caching**: Network response caching for improved performance
- **Background Processing**: Heavy operations off the main thread

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Clean Architecture principles
- Write comprehensive tests for new features
- Maintain code documentation
- Ensure all tests pass before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Rick and Morty API](https://rickandmortyapi.com/) for providing the character data
- Apple for SwiftUI and Swift Concurrency frameworks
- The iOS development community for best practices and patterns

## 📞 Support

For support, email [obada.semary@gmail.com] or create an issue in the repository.

---

**Built with ❤️ using SwiftUI and Clean Architecture**
