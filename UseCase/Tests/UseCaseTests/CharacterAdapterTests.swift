//
//  CharacterAdapterTests.swift
//  UseCaseTests
//
//  Created by Abdelrahman Mohamed on 02.09.2025.
//

import Testing
import Foundation
@testable import UseCase

struct CharacterAdapterTests {
    
    @Test("CharacterAdapter initializes correctly with all properties")
    func test_characterAdapter_initialization_shouldSetAllProperties() {
        // Given
        let id = 1
        let name = "Rick Sanchez"
        let status = Status.alive
        let species = "Human"
        let gender = Gender.male
        let location = "Earth (C-137)"
        let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
        
        // When
        let adapter = CharacterAdapter(
            id: id,
            name: name,
            status: status,
            species: species,
            gender: gender,
            location: location,
            image: imageURL
        )
        
        // Then
        #expect(adapter.id == id)
        #expect(adapter.name == name)
        #expect(adapter.status == status)
        #expect(adapter.species == species)
        #expect(adapter.gender == gender)
        #expect(adapter.location == location)
        #expect(adapter.image == imageURL)
    }
    
    @Test("CharacterAdapter handles nil location correctly")
    func test_characterAdapter_withNilLocation_shouldHandleCorrectly() {
        // When
        let adapter = CharacterAdapter(
            id: 1,
            name: "Morty Smith",
            status: .alive,
            species: "Human", 
            gender: .male,
            location: nil,
            image: nil
        )
        
        // Then
        #expect(adapter.location == nil)
        #expect(adapter.image == nil)
    }
    
    @Test("CharacterAdapter conforms to Identifiable")
    func test_characterAdapter_identifiable_shouldProvideCorrectId() {
        // Given
        let adapter = CharacterAdapter.mock(id: 42)
        
        // When & Then
        #expect(adapter.id == 42)
    }
    
    @Test("CharacterAdapter conforms to Hashable")
    func test_characterAdapter_hashable_shouldAllowSetOperations() {
        // Given
        let adapter1 = CharacterAdapter.mock(id: 1, name: "Rick")
        let adapter2 = CharacterAdapter.mock(id: 2, name: "Morty")
        let adapter3 = CharacterAdapter.mock(id: 1, name: "Rick") // Duplicate
        
        // When
        let characterSet = Set([adapter1, adapter2, adapter3])
        
        // Then
        #expect(characterSet.count == 2) // Should contain unique items only
        #expect(characterSet.contains(adapter1))
        #expect(characterSet.contains(adapter2))
    }
    
    @Test("CharacterAdapter equality works correctly")
    func test_characterAdapter_equality_shouldCompareCorrectly() {
        // Given
        let adapter1 = CharacterAdapter(
            id: 1,
            name: "Rick Sanchez",
            status: .alive,
            species: "Human",
            gender: .male,
            location: "Earth",
            image: URL(string: "https://example.com")
        )
        
        let adapter2 = CharacterAdapter(
            id: 1,
            name: "Rick Sanchez",
            status: .alive,
            species: "Human",
            gender: .male,
            location: "Earth",
            image: URL(string: "https://example.com")
        )
        
        let adapter3 = CharacterAdapter(
            id: 2,
            name: "Morty Smith",
            status: .alive,
            species: "Human",
            gender: .male,
            location: "Earth",
            image: URL(string: "https://example.com")
        )
        
        // Then
        #expect(adapter1 == adapter2)
        #expect(adapter1 != adapter3)
    }
}

// MARK: - CharacterResponse to CharacterAdapter Mapping Tests
struct CharacterResponseMappingTests {
    
    @Test("CharacterResponse maps to CharacterAdapter correctly")
    func test_characterResponse_toAdapter_shouldMapCorrectly() {
        // Given
        let characterResponse = CharacterResponse(
            id: 1,
            name: "Rick Sanchez",
            status: .alive,
            species: "Human",
            type: "Science",
            gender: .male,
            origin: APIReferenceResponse(
                name: "Earth (C-137)",
                url: URL(string: "https://example.com")
            ),
            location: APIReferenceResponse(
                name: "Citadel of Ricks",
                url: URL(string: "https://example.com")
            ),
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
        )
        
        // When
        let adapter = characterResponse.toAdapter()
        
        // Then
        #expect(adapter.id == 1)
        #expect(adapter.name == "Rick Sanchez")
        #expect(adapter.status == .alive)
        #expect(adapter.species == "Human")
        #expect(adapter.gender == .male)
        #expect(adapter.location == "Earth (C-137)") // Should prefer origin
        #expect(adapter.image?.absoluteString == "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
    }
    
    @Test("CharacterResponse prefers location when origin is unknown")
    func test_characterResponse_toAdapter_withUnknownOrigin_shouldUseLocation() {
        // Given
        let characterResponse = CharacterResponse(
            id: 2,
            name: "Morty Smith",
            status: .alive,
            species: "Human",
            type: "",
            gender: .male,
            origin: APIReferenceResponse(
                name: "unknown",
                url: nil
            ),
            location: APIReferenceResponse(
                name: "Earth (Replacement Dimension)",
                url: URL(string: "https://example.com")
            ),
            image: nil
        )
        
        // When
        let adapter = characterResponse.toAdapter()
        
        // Then
        #expect(adapter.location == "Earth (Replacement Dimension)")
    }
    
    @Test("CharacterResponse handles nil image correctly")
    func test_characterResponse_toAdapter_withNilImage_shouldHandleCorrectly() {
        // Given
        let characterResponse = CharacterResponse(
            id: 3,
            name: "Test Character",
            status: .unknown,
            species: "Alien",
            type: "",
            gender: .genderless,
            origin: APIReferenceResponse(name: "Unknown", url: nil),
            location: APIReferenceResponse(name: "Unknown", url: nil),
            image: nil
        )
        
        // When
        let adapter = characterResponse.toAdapter()
        
        // Then
        #expect(adapter.image == nil)
    }
    
    @Test("CharacterResponse handles case insensitive unknown origin")
    func test_characterResponse_toAdapter_withCaseInsensitiveUnknown_shouldUseLocation() {
        // Given
        let characterResponse = CharacterResponse(
            id: 4,
            name: "Test Character",
            status: .alive,
            species: "Human",
            type: "",
            gender: .female,
            origin: APIReferenceResponse(name: "UNKNOWN", url: nil),
            location: APIReferenceResponse(name: "Earth", url: nil),
            image: nil
        )
        
        // When
        let adapter = characterResponse.toAdapter()
        
        // Then
        #expect(adapter.location == "Earth")
    }
}

// MARK: - Mock Extensions
extension CharacterAdapter {
    static func mock(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: Status = .alive,
        species: String = "Human",
        gender: Gender = .male,
        location: String? = "Earth (C-137)",
        image: URL? = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
    ) -> CharacterAdapter {
        return CharacterAdapter(
            id: id,
            name: name,
            status: status,
            species: species,
            gender: gender,
            location: location,
            image: image
        )
    }
}

