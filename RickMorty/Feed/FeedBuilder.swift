//
//  FeedBuilder.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import UseCase
import DependencyContainer

@Observable
@MainActor
final class FeedBuilder {
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func buildFeedView() -> some View {
        FeedView(
            viewModel: FeedViewModel(
                feedUseCase: FeedUseCase(container: container)
            )
        )
    }
}
