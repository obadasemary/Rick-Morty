//
//  FeedBuilder.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import UseCase
import DependencyContainer
import DevPreview

@Observable
@MainActor
public final class FeedBuilder {
    private let container: DIContainer
    
    public init(container: DIContainer) {
        self.container = container
    }
    
    public func buildFeedView() -> some View {
        FeedView(
            viewModel: FeedViewModel(
                feedUseCase: FeedUseCase(container: container)
            )
        )
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
