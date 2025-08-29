//
//  CharacterAdapter.swift
//  FeedView
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import Foundation
import UseCase

// MARK: - Adapter (DTO -> UI/Domain)
public struct CharacterAdapter: Identifiable, Hashable, Sendable {
    
    public let id: Int
    public let name: String
    public let status: UseCase.Status
    public let species: String
    public let gender: UseCase.Gender
    public let image: URL?
}

public extension CharacterResponse {
    func toAdapter() -> CharacterAdapter {
        CharacterAdapter(
            id: id,
            name: name,
            status: status,
            species: species,
            gender: Gender(rawValue: gender.rawValue.capitalized) ?? .unknown,
            image: image
        )
    }
}

// If your page response type is available in this module, expose a convenience mapper too.
public extension CharactersPageResponse {
    var adapters: [CharacterAdapter] { results.map { $0.toAdapter() } }
}

