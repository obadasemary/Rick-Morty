//
//  DevPreview.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import UseCase
import RickMortyRepository
import DependencyContainer
import RickMortyNetworkLayer

@MainActor
class DevPreview {
    
    static let shared = DevPreview()
    
    var container: DIContainer {
        
        let container = DIContainer()
        
        container.register(NetworkService.self) {
            URLSessionNetworkService(session: .shared)
        }
        
        container.register(FeedRepositoryProtocol.self) {
            FeedRepository(
                networkService: container.resolve(NetworkService.self)!
            )
        }
        
        container.register(FeedUseCaseProtocol.self) {
            FeedUseCase(container: container)
        }
        
        return container
    }
}

extension View {
    func previewEnvironment() -> some View {
        self
            .environment(
                FeedBuilder(container: DevPreview.shared.container)
            )
    }
}
