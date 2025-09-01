//
//  FeedRouter.swift
//  FeedView
//
//  Created by Abdelrahman Mohamed on 31.08.2025.
//

import SUIRouting
import UseCase
import CharacterDetailsView

typealias RouterView = SUIRouting.RouterView

@MainActor
protocol FeedRouterProtocol {
    func showCharacterDetails(characterDetailsAdapter: CharacterAdapter)
}

@MainActor
struct FeedRouter {
    let router: Router
    let characterDetailsBuilder: CharacterDetailsBuilder
}

extension FeedRouter: FeedRouterProtocol {
    
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
