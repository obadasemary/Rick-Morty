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
    
    public var container: DIContainer {
        
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
