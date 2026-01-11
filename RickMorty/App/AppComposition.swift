//
//  AppComposition.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation
import SwiftUI
import UseCase
import DependencyContainer
import RickMortyRepository
import RickMortyNetworkLayer

@Observable
@MainActor
final class AppComposition {
    
    var container = DIContainer()
    let feedUseCase: FeedUseCaseProtocol?
    let isConfigured: Bool
    
    init() {
        let container = DIContainer()
        var configured = true
        var useCase: FeedUseCaseProtocol?
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")
        
        // Register NetworkService
        container.register(NetworkService.self, URLSessionNetworkService(session: .shared))
        
        // Register FeedRepository with safe resolution
        do {
            if isUITesting {
                container.register(FeedRepositoryProtocol.self, UITestFeedRepository())
            } else {
                let networkService = try container.requireResolve(NetworkService.self)
                container.register(FeedRepositoryProtocol.self, FeedRepository(networkService: networkService))
            }
            
            // Register FeedUseCase
            container.register(FeedUseCaseProtocol.self, FeedUseCase(container: container))
            
            // Resolve FeedUseCase
            useCase = try container.requireResolve(FeedUseCaseProtocol.self)
        } catch {
            print("Failed to configure dependencies: \(error)")
            configured = false
        }
        
        self.feedUseCase = useCase
        self.isConfigured = configured
        self.container = container
    }
}

@MainActor
private final class UITestFeedRepository: FeedRepositoryProtocol {
    private let characters: [CharacterResponse]
    private let pageSize: Int

    init(pageSize: Int = 20) {
        self.pageSize = pageSize
        self.characters = Self.makeCharacters()
    }

    func fetchCharacters(page: Int?, status: String?) async throws -> CharactersPageResponse {
        let requestedPage = max(1, page ?? 1)
        let normalizedStatus = status?.lowercased()
        let filtered = characters.filter { character in
            guard let normalizedStatus else { return true }
            return character.status.rawValue == normalizedStatus
        }

        let startIndex = (requestedPage - 1) * pageSize
        let pageItems = startIndex < filtered.count
            ? Array(filtered.dropFirst(startIndex).prefix(pageSize))
            : []

        let totalPages = max(1, Int(ceil(Double(filtered.count) / Double(pageSize))))
        let hasNext = requestedPage < totalPages

        let info = PageInfoResponse(
            count: filtered.count,
            pages: totalPages,
            next: hasNext ? URL(string: "https://example.com/page/\(requestedPage + 1)") : nil,
            prev: requestedPage > 1 ? URL(string: "https://example.com/page/\(requestedPage - 1)") : nil
        )

        return CharactersPageResponse(info: info, results: pageItems)
    }

    private static func makeCharacters() -> [CharacterResponse] {
        let origin = APIReferenceResponse(name: "Earth", url: nil)
        let location = APIReferenceResponse(name: "Citadel of Ricks", url: nil)
        let statuses: [Status] = [.alive, .dead, .unknown]
        let speciesOptions = ["Human", "Alien", "Robot"]
        let genderOptions: [Gender] = [.male, .female, .genderless]

        var items: [CharacterResponse] = []
        var id = 1

        for status in statuses {
            for index in 1...8 {
                let species = speciesOptions[(id - 1) % speciesOptions.count]
                let gender = genderOptions[(id - 1) % genderOptions.count]

                items.append(
                    CharacterResponse(
                        id: id,
                        name: "\(status.rawValue.capitalized) Character \(index)",
                        status: status,
                        species: species,
                        type: "",
                        gender: gender,
                        origin: origin,
                        location: location,
                        image: nil
                    )
                )
                id += 1
            }
        }

        return items
    }
}
