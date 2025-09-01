//
//  FeedListBuilder.swift
//  FeedListView
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import SwiftUI
import UseCase
import DependencyContainer
import DevPreview
import CharacterDetailsView
import SUIRouting

@Observable
@MainActor
public final class FeedListBuilder {
    private let container: DIContainer
    
    public init(container: DIContainer) {
        self.container = container
    }
    
    public func buildFeedListViewController(router: Router) -> some View {
        let viewModel = FeedListViewModel(
            feedUseCase: FeedUseCase(container: container),
            router: FeedListRouter(
                router: router,
                characterDetailsBuilder: CharacterDetailsBuilder(
                    container: container
                )
            )
        )
        
        return FeedListTabView(viewModel: viewModel)
    }
}

extension View {
    func previewEnvironment() -> some View {
        self
            .environment(
                FeedListBuilder(container: DevPreview.shared.container)
            )
            .environment(
                CharacterDetailsBuilder(container: DevPreview.shared.container)
            )
    }
}
