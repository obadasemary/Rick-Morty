//
//  FeedRepositoryProtocol.swift
//  UseCase
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation

@MainActor
public protocol FeedRepositoryProtocol {
    func fetchCharacters(page: Int?, status: String?) async throws -> CharactersPageResponse
}
