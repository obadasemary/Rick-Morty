//
//  CharacterResponse.swift
//  UseCase
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation

// MARK: - Character
public struct CharacterResponse: Decodable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let status: Status
    public let species: String
    public let type: String
    public let gender: Gender
    public let origin: APIReferenceResponse
    public let location: APIReferenceResponse
    public let image: URL?
    
    public init(
        id: Int,
        name: String,
        status: Status,
        species: String,
        type: String,
        gender: Gender,
        origin: APIReferenceResponse,
        location: APIReferenceResponse,
        image: URL?
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.origin = origin
        self.location = location
        self.image = image
    }
}

public struct APIReferenceResponse: Decodable, Hashable, Sendable {
    public let name: String
    public let url: URL?

    private enum CodingKeys: String, CodingKey {
        case name, url
    }

    public init(name: String, url: URL?) {
        self.name = name
        self.url = url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)

        // Decode URL as a String first, then create URL if valid and non-empty
        if let urlString = try? container.decode(String.self, forKey: .url),
           !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let parsed = URL(string: urlString) {
            self.url = parsed
        } else {
            self.url = nil
        }
    }
}

// MARK: - Enums (case-insensitive decoding)
public enum Status: String, Sendable, CaseIterable, Decodable {
    case alive
    case dead
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        self = Status(rawValue: raw) ?? .unknown
    }
}

public enum Gender: String, Sendable, CaseIterable, Decodable {
    case female
    case male
    case genderless
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        self = Gender(rawValue: raw) ?? .unknown
    }
}
