//
//  FeedUseCaseTests.swift
//  UseCaseTests
//
//  Created by Abdelrahman Mohamed on 02.09.2025.
//

import Testing
import Foundation
import DependencyContainer
@testable import UseCase

@MainActor
struct FeedUseCaseTests {
    
    // MARK: - Test Cases
    
    @Test("FeedUseCase executes successfully with valid response")
    func test_execute_withValidResponse_shouldReturnCharactersPageResponse() async throws {
        // Given
        let container = DIContainer()
        let mockRepository = MockFeedRepository()
        let expectedResponse = CharactersPageResponse.mock()
        mockRepository.fetchCharactersResult = .success(expectedResponse)
        
        container.register(FeedRepositoryProtocol.self) { mockRepository }
        
        let useCase = FeedUseCase(container: container)
        
        // When
        let result = try await useCase.execute(page: 1, status: "alive")
        
        // Then
        #expect(result.results.count == expectedResponse.results.count)
        #expect(result.info.count == expectedResponse.info.count)
        #expect(mockRepository.fetchCharactersCallCount == 1)
        #expect(mockRepository.lastFetchCharactersPage == 1)
        #expect(mockRepository.lastFetchCharactersStatus == "alive")
    }
    
    @Test("FeedUseCase executes with nil parameters")
    func test_execute_withNilParameters_shouldPassNilToRepository() async throws {
        // Given
        let container = DIContainer()
        let mockRepository = MockFeedRepository()
        container.register(FeedRepositoryProtocol.self) { mockRepository }
        let useCase = FeedUseCase(container: container)
        
        let expectedResponse = CharactersPageResponse.mock()
        mockRepository.fetchCharactersResult = .success(expectedResponse)
        
        // When
        let result = try await useCase.execute(page: nil, status: nil)
        
        // Then
        #expect(result.results.count == expectedResponse.results.count)
        #expect(mockRepository.fetchCharactersCallCount == 1)
        #expect(mockRepository.lastFetchCharactersPage == nil)
        #expect(mockRepository.lastFetchCharactersStatus == nil)
    }
    
    @Test("FeedUseCase throws error when repository fails")
    func test_execute_whenRepositoryFails_shouldThrowError() async throws {
        // Given
        let container = DIContainer()
        let mockRepository = MockFeedRepository()
        container.register(FeedRepositoryProtocol.self) { mockRepository }
        let useCase = FeedUseCase(container: container)
        
        let expectedError = FeedError.network
        mockRepository.fetchCharactersResult = .failure(expectedError)
        
        // When & Then
        await #expect(throws: FeedError.network) {
            try await useCase.execute(page: 1, status: "alive")
        }
        
        #expect(mockRepository.fetchCharactersCallCount == 1)
    }
    
    @Test("FeedUseCase handles server error correctly")
    func test_execute_withServerError_shouldThrowServerError() async throws {
        // Given
        let container = DIContainer()
        let mockRepository = MockFeedRepository()
        container.register(FeedRepositoryProtocol.self) { mockRepository }
        let useCase = FeedUseCase(container: container)
        
        let expectedError = FeedError.server(status: 500)
        mockRepository.fetchCharactersResult = .failure(expectedError)
        
        // When & Then
        await #expect(throws: FeedError.server(status: 500)) {
            try await useCase.execute(page: 1, status: "dead")
        }
    }
    
    @Test("FeedUseCase handles decoding error correctly")
    func test_execute_withDecodingError_shouldThrowDecodingError() async throws {
        // Given
        let container = DIContainer()
        let mockRepository = MockFeedRepository()
        container.register(FeedRepositoryProtocol.self) { mockRepository }
        let useCase = FeedUseCase(container: container)
        
        mockRepository.fetchCharactersResult = .failure(FeedError.decoding)
        
        // When & Then
        await #expect(throws: FeedError.decoding) {
            try await useCase.execute(page: 1, status: "unknown")
        }
    }
    
    @Test("FeedUseCase executes multiple times correctly")
    func test_execute_multipleCalls_shouldTrackCallsCorrectly() async throws {
        // Given
        let container = DIContainer()
        let mockRepository = MockFeedRepository()
        container.register(FeedRepositoryProtocol.self) { mockRepository }
        let useCase = FeedUseCase(container: container)
        
        let response1 = CharactersPageResponse.mock(withCharacterCount: 2)
        let response2 = CharactersPageResponse.mock(withCharacterCount: 3)
        
        // When
        mockRepository.fetchCharactersResult = .success(response1)
        let result1 = try await useCase.execute(page: 1, status: "alive")
        
        mockRepository.fetchCharactersResult = .success(response2)
        let result2 = try await useCase.execute(page: 2, status: "dead")
        
        // Then
        #expect(result1.results.count == 2)
        #expect(result2.results.count == 3)
        #expect(mockRepository.fetchCharactersCallCount == 2)
    }
}

// MARK: - Mock Repository
@MainActor
final class MockFeedRepository: FeedRepositoryProtocol {
    
    var fetchCharactersResult: Result<CharactersPageResponse, Error> = .success(CharactersPageResponse.mock())
    var fetchCharactersCallCount = 0
    var lastFetchCharactersPage: Int?
    var lastFetchCharactersStatus: String?
    
    func fetchCharacters(page: Int?, status: String?) async throws -> CharactersPageResponse {
        fetchCharactersCallCount += 1
        lastFetchCharactersPage = page
        lastFetchCharactersStatus = status
        
        switch fetchCharactersResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Tests now use proper DIContainer pattern as shown in the example

// MARK: - Mock Data Extensions
extension CharactersPageResponse {
    static func mock(withCharacterCount count: Int = 1) -> CharactersPageResponse {
        let characters = (0..<count).map { index in
            CharacterResponse.mock(id: index + 1, name: "Character \(index + 1)")
        }
        
        return CharactersPageResponse(
            info: PageInfoResponse.mock(),
            results: characters
        )
    }
}

extension CharacterResponse {
    static func mock(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: Status = .alive,
        species: String = "Human",
        gender: Gender = .male
    ) -> CharacterResponse {
        return CharacterResponse(
            id: id,
            name: name,
            status: status,
            species: species,
            type: "",
            gender: gender,
            origin: APIReferenceResponse.mock(name: "Earth (C-137)"),
            location: APIReferenceResponse.mock(name: "Citadel of Ricks"),
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg")
        )
    }
}

extension PageInfoResponse {
    static func mock(
        count: Int = 826,
        pages: Int = 42,
        next: String? = "https://rickandmortyapi.com/api/character?page=2",
        prev: String? = nil
    ) -> PageInfoResponse {
        return PageInfoResponse(
            count: count,
            pages: pages,
            next: next != nil ? URL(string: next!) : nil,
            prev: prev != nil ? URL(string: prev!) : nil
        )
    }
}

extension APIReferenceResponse {
    static func mock(
        name: String = "Earth (C-137)",
        url: String = "https://rickandmortyapi.com/api/location/1"
    ) -> APIReferenceResponse {
        return APIReferenceResponse(name: name, url: URL(string: url))
    }
}
