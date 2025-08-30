//
//  CharacterDetailsViewModel.swift
//  CharacterDetailsView
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import Foundation
import UseCase

@Observable
@MainActor
final class CharacterDetailsViewModel {
    
    private let feedUseCase: FeedUseCaseProtocol
    
    // Internal for testing, private(set) for external access
    internal private(set) var character: CharacterDetailsAdapter
    private let backAction: () -> Void
    
    init(
        feedUseCase: FeedUseCaseProtocol,
        character: CharacterDetailsAdapter,
        backAction: @escaping () -> Void
    ) {
        self.feedUseCase = feedUseCase
        self.character = character
        self.backAction = backAction
    }
    
    func back() {
        backAction()
    }
}
