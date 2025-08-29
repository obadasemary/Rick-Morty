//
//  CharacterAdapter.swift
//  CharacterDetailsView
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import Foundation
import UseCase

public struct CharacterDetailsAdapter: Identifiable, Hashable, Sendable {
    
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

public extension CharacterDetailsAdapter {
    
    static let mock = CharacterDetailsAdapter(
        id: 1,
        name: "Obada",
        status: .alive,
        species: "Human",
        gender: .male,
        image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
    )
}

public extension CharacterResponse {
    func toAdapter() -> CharacterDetailsAdapter {
        CharacterDetailsAdapter(
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
    var adapters: [CharacterDetailsAdapter] { results.map { $0.toAdapter() } }
}
