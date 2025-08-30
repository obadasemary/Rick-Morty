//
//  FeedBuilder.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import UIKit
import UseCase
import DependencyContainer
import DevPreview
import CharacterDetailsView
import SUIRouting

@Observable
@MainActor
public final class FeedBuilder {
    private let container: DIContainer
    
    public init(container: DIContainer) {
        self.container = container
    }
    
    public func buildFeedViewController(router: Router) -> UIViewController {
        let viewModel = FeedViewModel(
            feedUseCase: FeedUseCase(container: container),
            router: FeedRouter(
                router: router,
                characterDetailsBuilder: CharacterDetailsBuilder(
                    container: container
                )
            )
        )
        
        let feedViewController = FeedViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: feedViewController)
        return navigationController
    }
}
