//
//  FeedRouter.swift
//  FeedView
//
//  Created by Abdelrahman Mohamed on 31.08.2025.
//

import SUIRouting
import CharacterDetailsView

typealias RouterView = SUIRouting.RouterView

@MainActor
protocol FeedRouterProtocol {
    func showCharacterDetails(characterDetailsAdapter: CharacterDetailsAdapter)
    func dismissScreen()
}

@MainActor
struct FeedRouter {
    let router: Router
    let characterDetailsBuilder: CharacterDetailsBuilder
}

extension FeedRouter: FeedRouterProtocol {
    
    func showCharacterDetails(
        characterDetailsAdapter: CharacterDetailsAdapter
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
    
    func dismissScreen() {
        router.dismissScreen()
    }
}
