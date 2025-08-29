//
//  CharacterDetailsBuilder.swift
//  CharacterDetailsView
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import SwiftUI
import UseCase
import DependencyContainer
import DevPreview


@Observable
@MainActor
public final class CharacterDetailsBuilder {
    private let container: DIContainer
    
    public init(container: DIContainer) {
        self.container = container
    }
    
    public func buildCharacterDetailsView(
        characterDetailsAdapter: CharacterDetailsAdapter,
        backAction: @escaping () -> Void
    ) -> some View {
        let feedUseCase: FeedUseCaseProtocol = FeedUseCase(container: container)
        let viewModel = CharacterDetailsViewModel(
            feedUseCase: feedUseCase,
            character: characterDetailsAdapter,
            backAction: backAction
        )
        return CharacterDetailsView(viewModel: viewModel)
    }
}

extension View {
    func previewEnvironment() -> some View {
        self
            .environment(
                CharacterDetailsBuilder(container: DevPreview.shared.container)
            )
    }
}
