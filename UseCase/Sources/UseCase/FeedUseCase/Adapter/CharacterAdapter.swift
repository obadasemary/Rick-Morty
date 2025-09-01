//
//  CharacterAdapter.swift
//  UseCase
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import Foundation

// MARK: - Adapter (DTO -> UI/Domain)
public struct CharacterAdapter: Identifiable, Hashable, Sendable {
    
    public let id: Int
    public let name: String
    public let status: UseCase.Status
    public let species: String
    public let gender: UseCase.Gender
    public let image: URL?
    
    public init(
        id: Int,
        name: String,
        status: UseCase.Status,
        species: String,
        gender: UseCase.Gender,
        image: URL?
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.gender = gender
        self.image = image
    }
}

public extension CharacterAdapter {
    
    static let mock = CharacterAdapter(
        id: 1,
        name: "Obada",
        status: .alive,
        species: "Human",
        gender: .male,
        image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
    )
}

public extension CharacterResponse {
    func toAdapter() -> CharacterAdapter {
        CharacterAdapter(
            id: id,
            name: name,
            status: status,
            species: species,
            gender: gender,
            image: image
        )
    }
}

// If your page response type is available in this module, expose a convenience mapper too.
public extension CharactersPageResponse {
    var adapters: [CharacterAdapter] { results.map { $0.toAdapter() } }
}

