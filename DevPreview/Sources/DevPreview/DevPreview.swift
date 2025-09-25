//
//  DevPreview.swift
//  DevPreview
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import UseCase
import RickMortyRepository
import DependencyContainer
import RickMortyNetworkLayer

@MainActor
public class DevPreview {
    
    public static let shared = DevPreview()
    
    private var _container: DIContainer?
    
    public var container: DIContainer {
        if let existingContainer = _container {
            return existingContainer
        }
        
        let container = DIContainer()
        
        // Register NetworkService first
        container.register(NetworkService.self, URLSessionNetworkService(session: .shared))
        
        // Register FeedRepository with safe resolution
        do {
            let networkService = try container.requireResolve(NetworkService.self)
            container.register(FeedRepositoryProtocol.self, FeedRepository(networkService: networkService))
            
            // Register FeedUseCase
            container.register(FeedUseCaseProtocol.self, FeedUseCase(container: container))
            
            _container = container
            return container
            
        } catch {
            print("DevPreview: Failed to setup container: \(error)")
            // Return a minimal working container for previews
            return createFallbackContainer()
        }
    }
    
    private func createFallbackContainer() -> DIContainer {
        let fallbackContainer = DIContainer()
        // You could register mock implementations here if needed
        // For now, return empty container to prevent crashes
        return fallbackContainer
    }
    
    // Helper method to reset the container for testing
    public func resetContainer() {
        _container = nil
    }
}
