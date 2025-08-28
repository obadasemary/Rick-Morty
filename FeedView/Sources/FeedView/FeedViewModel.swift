//
//  FeedViewModel.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation
import UseCase

@Observable
@MainActor
class FeedViewModel {
    
    private let feedUseCase: FeedUseCaseProtocol
    
    // Internal for testing, private(set) for external access
    internal private(set) var characters: CharactersPageResponse? = nil
    
    init(feedUseCase: FeedUseCaseProtocol) {
        self.feedUseCase = feedUseCase
    }
}

extension FeedViewModel {
    
    func fetchCharacters() async {
        do {
            characters = try await feedUseCase.execute(page: 1, status: nil)
        } catch {
            print("Failed to fetch characters: \(error)")
        }
    }
}
