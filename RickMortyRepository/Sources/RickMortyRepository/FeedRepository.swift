//
//  FeedRepository.swift
//  RickMortyRepository
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation
import RickMortyNetworkLayer
import CoreAPI
import UseCase

@MainActor
@Observable
public final class FeedRepository {
    
    private let networkService: NetworkService
    
    public init(networkService: NetworkService) {
        self.networkService = networkService
    }
}

extension FeedRepository: FeedRepositoryProtocol {
    
    public func fetchCharacters(page: Int?, status: String?) async throws -> UseCase.CharactersPageResponse {
        let endPoint = CoreAPI.RickMortyEndpoint.getCharacters(page: page, status: status)
        return try await networkService.request(
            endpoint: endPoint,
            responseModel: UseCase.CharactersPageResponse.self
        )
    }
}
