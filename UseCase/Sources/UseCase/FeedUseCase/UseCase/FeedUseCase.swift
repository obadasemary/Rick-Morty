//
//  FeedUseCase.swift
//  UseCase
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation
import DependencyContainer

@MainActor
public protocol FeedUseCaseProtocol {
    func execute(page: Int?, status: String?) async throws -> CharactersPageResponse
}

@Observable
@MainActor
public final class FeedUseCase {
    
    private let feedRepositoryProtocol: FeedRepositoryProtocol
    
    public init(container: DIContainer) {
        self.feedRepositoryProtocol = container.resolve(FeedRepositoryProtocol.self)!
    }
}

extension FeedUseCase: FeedUseCaseProtocol {
    public func execute(
        page: Int? = nil,
        status: String? = nil
    ) async throws -> CharactersPageResponse {
        let response = try await feedRepositoryProtocol
            .fetchCharacters(page: page, status: status)
        return response
    }
}
