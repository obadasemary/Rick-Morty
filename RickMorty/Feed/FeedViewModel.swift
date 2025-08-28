//
//  FeedViewModel.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation
import UseCase

@Observable
@MainActor
class FeedViewModel {
    
    private let feedUseCase: FeedUseCaseProtocol
    
    // Internal for testing, private(set) for external access
    internal private(set) var characters: CharactersPageResponse? = nil
    
    init(feedUseCase: FeedUseCaseProtocol) {
        self.feedUseCase = feedUseCase
    }
}

extension FeedViewModel {
    
    func fetchCharacters() async {
        do {
            characters = try await feedUseCase.execute(page: 1, status: nil)
        } catch {
            print("Failed to fetch characters: \(error)")
        }
    }
}

//// MARK: - Adapter (DTO -> UI/Domain)
//public struct CharacterAdapter: Identifiable, Hashable, Sendable {
//    public let id: Int
//    public let name: String
//    public let status: String
//    public let species: String
//    public let type: String?
//    public let gender: String
////    public let originName: String
////    public let originURL: URL?
////    public let locationName: String
////    public let locationURL: URL?
//    public let imageURL: URL?
//}
//
//public extension Character {
//    func toAdapter() -> CharacterAdapter {
//        CharacterAdapter(
//            id: id,
//            name: name,
//            status: status.rawValue.capitalized,
//            species: species,
//            type: type.isEmpty ? nil : type,
//            gender: gender.rawValue.capitalized,
////            originName: origin.name,
////            originURL: origin.url,
////            locationName: location.name,
////            locationURL: location.url,
//            imageURL: image,
////            episodeURLs: episode,
////            createdAt: ISO8601DateFormatter().date(from: created)
//        )
//    }
//}
//
//// If your page response type is available in this module, expose a convenience mapper too.
//public extension CharactersPageResponse {
//    var adapters: [CharacterAdapter] { results.map { $0.toAdapter() } }
//}
