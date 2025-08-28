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
    public let status: CharacterStatusResponse
    public let species: String
    public let type: String
    public let gender: CharacterGenderResponse
    public let origin: APIReferenceResponse
    public let location: APIReferenceResponse
    public let image: URL?
    public let episode: [URL]
    public let url: URL?
    public let created: String
}

public struct APIReferenceResponse: Decodable, Hashable, Sendable {
    public let name: String
    public let url: URL?

    private enum CodingKeys: String, CodingKey {
        case name, url
    }
}

// MARK: - Enums (case-insensitive decoding)
public enum CharacterStatusResponse: String, Sendable, CaseIterable, Decodable {
    case alive
    case dead
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        self = CharacterStatusResponse(rawValue: raw) ?? .unknown
    }
}

public enum CharacterGenderResponse: String, Sendable, CaseIterable, Decodable {
    case female
    case male
    case genderless
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        self = CharacterGenderResponse(rawValue: raw) ?? .unknown
    }
}
