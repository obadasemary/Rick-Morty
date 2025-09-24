//
//  AppComposition.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import UseCase
import DependencyContainer
import RickMortyRepository
import RickMortyNetworkLayer

@Observable
@MainActor
final class AppComposition {
    
    var container = DIContainer()
    let feedUseCase: FeedUseCaseProtocol?
    let isConfigured: Bool
    
    init() {
        let container = DIContainer()
        var configured = true
        var useCase: FeedUseCaseProtocol?
        
        // Register NetworkService
        container.register(NetworkService.self, URLSessionNetworkService(session: .shared))
        
        // Register FeedRepository with safe resolution
        do {
            let networkService = try container.requireResolve(NetworkService.self)
            container.register(FeedRepositoryProtocol.self, FeedRepository(networkService: networkService))
            
            // Register FeedUseCase
            container.register(FeedUseCaseProtocol.self, FeedUseCase(container: container))
            
            // Resolve FeedUseCase
            useCase = try container.requireResolve(FeedUseCaseProtocol.self)
        } catch {
            print("Failed to configure dependencies: \(error)")
            configured = false
        }
        
        self.feedUseCase = useCase
        self.isConfigured = configured
        self.container = container
    }
}
