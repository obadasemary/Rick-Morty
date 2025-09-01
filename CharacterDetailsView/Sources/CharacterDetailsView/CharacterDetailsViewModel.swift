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
    
    internal private(set) var character: CharacterAdapter
    private let backAction: () -> Void
    
    init(
        feedUseCase: FeedUseCaseProtocol,
        character: CharacterAdapter,
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
