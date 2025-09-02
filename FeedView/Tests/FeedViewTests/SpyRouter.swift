//
//  SpyRouter.swift
//  FeedViewTests
//
//  Created by Abdelrahman Mohamed on 02.09.2025.
//

import Foundation
import UseCase
@testable import FeedView

final class SpyRouter: FeedRouterProtocol {
    
    private(set) var received: CharacterAdapter?
    
    func showCharacterDetails(characterDetailsAdapter: CharacterAdapter) {
        received = characterDetailsAdapter
    }
}
