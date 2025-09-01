//
//  FeedListRouter.swift
//  FeedListView
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import SUIRouting
import UseCase
import CharacterDetailsView

typealias RouterView = SUIRouting.RouterView

@MainActor
protocol FeedListRouterProtocol {
    func showCharacterDetails(characterDetailsAdapter: CharacterAdapter)
}

@MainActor
struct FeedListRouter {
    let router: Router
    let characterDetailsBuilder: CharacterDetailsBuilder
}

extension FeedListRouter: FeedListRouterProtocol {
    
    func showCharacterDetails(
        characterDetailsAdapter: CharacterAdapter
    ) {
        router.showScreen(.push) { innerRouter in
            characterDetailsBuilder
                .buildCharacterDetailsView(
                    characterDetailsAdapter: characterDetailsAdapter,
                    backAction: {
                        innerRouter.dismissScreen()
                    }
                )
        }
    }
}
