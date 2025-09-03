//
//  FeedRepositoryTests.swift
//  RickMortyRepositoryTests
//
//  Created by Abdelrahman Mohamed on 03.09.2025.
//

import Foundation
import Testing
import RickMortyNetworkLayer
import CoreAPI
import UseCase
@testable import RickMortyRepository

@MainActor
@Suite("FeedRepository • Unit Tests")
struct FeedRepositoryTests {
    
    // MARK: - Initialization Tests
    
    @Test("FeedRepository initializes correctly")
    func test_feedRepository_initialization_shouldSetNetworkService() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        
        // When
        let repository = FeedRepository(networkService: mockNetworkService)
        
        // Then
        #expect(repository.networkService is MockNetworkService)
    }
    
    // MARK: - Fetch Characters Tests
    
    @Test("fetchCharacters with nil parameters should call network service with correct endpoint")
    func test_fetchCharacters_withNilParameters_shouldCallNetworkService() async throws {
        // Given
        let (repository, mockNetworkService) = makeSUT()
        let expectedResponse = charactersPageResponse(ids: [1, 2, 3])
        mockNetworkService.setResponse(expectedResponse)
        
        // When
        let result = try await repository.fetchCharacters(page: nil, status: nil)
        
        // Then
        #expect(mockNetworkService.getCallCount() == 1)
        #expect(result.info.count == 3)
        #expect(result.results.count == 3)
    }
    
    @Test("fetchCharacters with page parameter should call network service")
    func test_fetchCharacters_withPageParameter_shouldCallNetworkService() async throws {
        // Given
        let (repository, mockNetworkService) = makeSUT()
        let expectedResponse = charactersPageResponse(ids: [4, 5, 6])
        mockNetworkService.setResponse(expectedResponse)
        
        // When
        let result = try await repository.fetchCharacters(page: 2, status: nil)
        
        // Then
        #expect(mockNetworkService.getCallCount() == 1)
        #expect(result.info.count == 3)
        #expect(result.results.count == 3)
    }
    
    @Test("fetchCharacters with status parameter should call network service")
    func test_fetchCharacters_withStatusParameter_shouldCallNetworkService() async throws {
        // Given
        let (repository, mockNetworkService) = makeSUT()
        let expectedResponse = charactersPageResponse(ids: [7, 8, 9])
        mockNetworkService.setResponse(expectedResponse)
        
        // When
        let result = try await repository.fetchCharacters(page: nil, status: "alive")
        
        // Then
        #expect(mockNetworkService.getCallCount() == 1)
        #expect(result.info.count == 3)
        #expect(result.results.count == 3)
    }
    
    @Test("fetchCharacters with both parameters should call network service")
    func test_fetchCharacters_withBothParameters_shouldCallNetworkService() async throws {
        // Given
        let (repository, mockNetworkService) = makeSUT()
        let expectedResponse = charactersPageResponse(ids: [10, 11, 12])
        mockNetworkService.setResponse(expectedResponse)
        
        // When
        let result = try await repository.fetchCharacters(page: 3, status: "dead")
        
        // Then
        #expect(mockNetworkService.getCallCount() == 1)
        #expect(result.info.count == 3)
        #expect(result.results.count == 3)
    }
    
    @Test("fetchCharacters with empty results should handle correctly")
    func test_fetchCharacters_withEmptyResults_shouldHandleCorrectly() async throws {
        // Given
        let (repository, mockNetworkService) = makeSUT()
        let expectedResponse = charactersPageResponse(ids: [])
        mockNetworkService.setResponse(expectedResponse)
        
        // When
        let result = try await repository.fetchCharacters(page: nil, status: nil)
        
        // Then
        #expect(mockNetworkService.getCallCount() == 1)
        #expect(result.info.count == 0)
        #expect(result.results.count == 0)
    }
    
    @Test("fetchCharacters with pagination info should handle correctly")
    func test_fetchCharacters_withPaginationInfo_shouldHandleCorrectly() async throws {
        // Given
        let (repository, mockNetworkService) = makeSUT()
        let expectedResponse = charactersPageResponse(ids: [1, 2, 3], hasNext: true)
        mockNetworkService.setResponse(expectedResponse)
        
        // When
        let result = try await repository.fetchCharacters(page: nil, status: nil)
        
        // Then
        #expect(mockNetworkService.getCallCount() == 1)
        #expect(result.info.count == 3)
        #expect(result.info.pages == 2)
        #expect(result.info.next != nil)
        #expect(result.info.prev == nil)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("fetchCharacters when network service throws error should propagate error")
    func test_fetchCharacters_whenNetworkServiceThrowsError_shouldPropagateError() async throws {
        // Given
        let (repository, mockNetworkService) = makeSUT()
        let expectedError = NetworkError.invalidResponse
        mockNetworkService.setError(expectedError)
        
        // When & Then
        await #expect(throws: NetworkError.self) {
            try await repository.fetchCharacters(page: nil, status: nil)
        }
        
        #expect(mockNetworkService.getCallCount() == 1)
    }
    
    @Test("fetchCharacters when network service throws network error should propagate error")
    func test_fetchCharacters_whenNetworkServiceThrowsNetworkError_shouldPropagateError() async throws {
        // Given
        let (repository, mockNetworkService) = makeSUT()
        let expectedError = NetworkError.networkError
        mockNetworkService.setError(expectedError)
        
        // When & Then
        await #expect(throws: NetworkError.self) {
            try await repository.fetchCharacters(page: 1, status: "alive")
        }
        
        #expect(mockNetworkService.getCallCount() == 1)
    }
    
    @Test("fetchCharacters when network service throws decoding error should propagate error")
    func test_fetchCharacters_whenNetworkServiceThrowsDecodingError_shouldPropagateError() async throws {
        // Given
        let (repository, mockNetworkService) = makeSUT()
        let expectedError = NetworkError.decodingError
        mockNetworkService.setError(expectedError)
        
        // When & Then
        await #expect(throws: NetworkError.self) {
            try await repository.fetchCharacters(page: nil, status: "dead")
        }
        
        #expect(mockNetworkService.getCallCount() == 1)
    }
    
    // MARK: - Multiple Calls Tests
    
    @Test("fetchCharacters multiple calls should work correctly")
    func test_fetchCharacters_multipleCalls_shouldWorkCorrectly() async throws {
        // Given
        let (repository, mockNetworkService) = makeSUT()
        let response1 = charactersPageResponse(ids: [1, 2, 3])
        let response2 = charactersPageResponse(ids: [4, 5, 6])
        mockNetworkService.setResponse(response1)
        mockNetworkService.setResponse(response2)
        
        // When
        let result1 = try await repository.fetchCharacters(page: 1, status: nil)
        let result2 = try await repository.fetchCharacters(page: 2, status: "alive")
        
        // Then
        #expect(mockNetworkService.getCallCount() == 2)
        #expect(result1.info.count == 3)
        #expect(result2.info.count == 3)
        #expect(result1.results.first?.id == 1)
        #expect(result2.results.first?.id == 4)
    }
    
    // MARK: - Protocol Conformance Tests
    
    @Test("FeedRepository should conform to FeedRepositoryProtocol")
    func test_feedRepository_shouldConformToFeedRepositoryProtocol() async throws {
        // Given
        let (repository, _) = makeSUT()
        
        // When & Then
        let protocolRepository: FeedRepositoryProtocol = repository
        #expect(protocolRepository is FeedRepository)
    }
}

private extension FeedRepositoryTests {
    
    // MARK: - SUT Plumbing
    
    func makeSUT() -> (FeedRepository, MockNetworkService) {
        let mockNetworkService = MockNetworkService()
        let repository = FeedRepository(networkService: mockNetworkService)
        return (repository, mockNetworkService)
    }
    
    // MARK: - Test Data Builders
    
    func characterResponse(id: Int) -> CharacterResponse {
        CharacterResponse(
            id: id,
            name: "Rick \(id)",
            status: .alive,
            species: "Human",
            type: "",
            gender: .male,
            origin: APIReferenceResponse(name: "Earth", url: URL(string: "https://example.com")!),
            location: APIReferenceResponse(name: "Earth", url: URL(string: "https://example.com")!),
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg")!
        )
    }
    
    func charactersPageResponse(ids: [Int], hasNext: Bool = false) -> CharactersPageResponse {
        CharactersPageResponse(
            info: PageInfoResponse(
                count: ids.count,
                pages: hasNext ? 2 : 1,
                next: hasNext ? URL(string: "https://example.com/next")! : nil,
                prev: nil
            ),
            results: ids.map(characterResponse(id:))
        )
    }
}
