//
//  DevPreview.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation
import SwiftUI
import DependencyContainer
import RickMortyNetworkLayer
import CoreAPI
import RickMortyRepository
import UseCase

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
            
    }
}
