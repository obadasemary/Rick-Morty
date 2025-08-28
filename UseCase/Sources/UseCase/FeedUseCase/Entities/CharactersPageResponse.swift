//
//  CharactersPageResponse.swift
//  UseCase
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation

// MARK: - Top-level page payload
public struct CharactersPageResponse: Decodable, Sendable {
    public let info: PageInfoResponse
    public let results: [CharacterResponse]
}
