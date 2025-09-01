//
//  AppComposition.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import Foundation
import UseCase
import DependencyContainer
import RickMortyRepository
import RickMortyNetworkLayer

@Observable
@MainActor
final class AppComposition {
    
    var container = DIContainer()
    let feedUseCase: FeedUseCaseProtocol
    
    init() {
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
        
        feedUseCase = container.resolve(FeedUseCaseProtocol.self)!
        self.container = container
    }
    
    
    // MARK: - Factories
    public func makeFeedListViewModel() -> FeedListViewModel {
        FeedListViewModel(feedUseCase: feedUseCase)
    }
}
