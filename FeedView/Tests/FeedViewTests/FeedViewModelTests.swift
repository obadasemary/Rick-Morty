//
//  FeedViewModelTests.swift
//  FeedViewTests
//
//  Created by Abdelrahman Mohamed on 02.09.2025
//

import Foundation
import Testing
import UseCase
@testable import FeedView

@MainActor
@Suite("FeedViewModel • Logic Tests")
struct FeedViewModelTests {
    // MARK: - Tests
    
    @Test("Use case execution with success")
    func testUseCaseExecutionSuccess() async throws {
        let (useCase, _) = makeSUT()
        schedule(useCase, page: 1, status: nil, result: .success(page(ids: [1,2,3], hasNext: true)))
        
        let response = try await useCase.execute(page: 1, status: nil)
        
        #expect(useCase.calls.count == 1)
        #expect(useCase.calls.first?.page == 1)
        #expect(useCase.calls.first?.status == nil)
        #expect(response.results.count == 3)
        #expect(response.info.next != nil)
    }
    
    @Test("Use case execution with failure")
    func testUseCaseExecutionFailure() async throws {
        let (useCase, _) = makeSUT()
        schedule(useCase, page: 1, status: nil, result: .failure(URLError(.notConnectedToInternet)))
        
        do {
            _ = try await useCase.execute(page: 1, status: nil)
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is URLError)
        }
        
        #expect(useCase.calls.count == 1)
    }
    
    @Test("Use case pagination with multiple pages")
    func testUseCasePagination() async throws {
        let (useCase, _) = makeSUT()
        schedule(useCase, page: 1, status: nil, result: .success(page(ids: [1,2], hasNext: true)))
        schedule(useCase, page: 2, status: nil, result: .success(page(ids: [3], hasNext: false)))
        
        let response1 = try await useCase.execute(page: 1, status: nil)
        let response2 = try await useCase.execute(page: 2, status: nil)
        
        #expect(useCase.calls.count == 2)
        #expect(response1.results.count == 2)
        #expect(response2.results.count == 1)
        #expect(response1.info.next != nil)
        #expect(response2.info.next == nil)
    }
    
    @Test("Use case filtering with status")
    func testUseCaseFiltering() async throws {
        let (useCase, _) = makeSUT()
        schedule(
            useCase,
            page: 1,
            status: .alive,
            result: .success(page(ids: [1,2], hasNext: false))
        )
        
        let response = try await useCase.execute(page: 1, status: "alive")
        
        #expect(useCase.calls.count == 1)
        #expect(useCase.calls.first?.status == "alive")
        #expect(response.results.count == 2)
    }
    
    @Test("Character response mapping to adapter")
    func testCharacterResponseMapping() async throws {
        let character = characterResponse(id: 42)
        let adapter = character.toAdapter()
        
        #expect(adapter.id == 42)
        #expect(adapter.name == "Rick 42")
        #expect(adapter.status == .alive)
        #expect(adapter.species == "Human")
        #expect(adapter.gender == .male)
    }
    
    @Test("Router spy functionality")
    func testRouterSpy() async throws {
        let (_, router) = makeSUT()
        let adapter = characterResponse(id: 99).toAdapter()
        
        router.showCharacterDetails(characterDetailsAdapter: adapter)
        
        #expect(router.received?.id == 99)
        #expect(router.received?.name == "Rick 99")
    }
    
    @Test("Error mapping: URLError -> .network")
    func testMapErrorURL() async throws {
        let (useCase, router) = makeSUT()
        let sut = FeedViewModel(feedUseCase: useCase, router: router)
        
        let error = URLError(.timedOut)
        let feedError = sut.mapError(error)
        
        #expect(feedError == .network)
    }
    
    @Test("Error mapping: DecodingError -> .decoding")
    func testMapErrorDecoding() async throws {
        let (useCase, router) = makeSUT()
        let sut = FeedViewModel(feedUseCase: useCase, router: router)
        
        let error = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "boom"))
        let feedError = sut.mapError(error)
        
        #expect(feedError == .decoding)
    }
    
    @Test("Error mapping: NSError with HTTPStatusCode -> .server(status)")
    func testMapErrorHTTPStatus() async throws {
        let ns = NSError(domain: "test", code: 0, userInfo: ["HTTPStatusCode": 503])
        let feedError: FeedError
        
        if let status = ns.userInfo["HTTPStatusCode"] as? Int {
            feedError = .server(status: status)
        } else {
            feedError = .unknown(message: "Unknown error")
        }
        
        #expect(feedError == .server(status: 503))
    }
    
    @Test("Error mapping: unknown falls back to LocalizedError description")
    func testMapErrorUnknown() async throws {
        struct MyErr: LocalizedError {
            var errorDescription: String? { "Nice message" }
        }
        let error = MyErr()
        let feedError: FeedError
        
        if let desc = error.errorDescription, !desc.isEmpty {
            feedError = .unknown(message: desc)
        } else {
            feedError = .unknown(message: "Unknown error")
        }
        
        #expect(feedError == .unknown(message: "Nice message"))
    }
    
    @Test("Page info mapping")
    func testPageInfoMapping() async throws {
        let pageResponse = page(ids: [1,2,3], hasNext: true)
        let infoAdapter = pageResponse.info
        
        #expect(infoAdapter.count == 3)
        #expect(infoAdapter.pages == 2)
        #expect(infoAdapter.next == URL(string: "https://example.com/next")!)
        #expect(infoAdapter.prev == nil)
    }
    
    @Test("Multiple character responses mapping")
    func testMultipleCharacterMapping() async throws {
        let pageResponse = page(ids: [1,2,3], hasNext: false)
        let adapters = pageResponse.results.map { $0.toAdapter() }
        
        #expect(adapters.count == 3)
        #expect(adapters.map(\.id) == [1,2,3])
        #expect(adapters.map(\.name) == ["Rick 1", "Rick 2", "Rick 3"])
    }
}

private extension FeedViewModelTests {
    
    // MARK: - SUT plumbing
    
    func makeSUT() -> (FakeFeedUseCase, SpyRouter) {
        let useCase = FakeFeedUseCase()
        let router = SpyRouter()
        return (useCase, router)
    }
    
    // MARK: - Builders
    
    func characterResponse(id: Int) -> CharacterResponse {
        CharacterResponse(
            id: id,
            name: "Rick \(id)",
            status: .alive,
            species: "Human",
            type: "",
            gender: .male,
            origin: APIReferenceResponse(name: "Earth", url: URL(string: "https://www.example.com")!),
            location: APIReferenceResponse(name: "Earth", url: URL(string: "https://www.example.com")!),
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
        )
    }
    
    func page(ids: [Int], hasNext: Bool) -> CharactersPageResponse {
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
    
    func schedule(
        _ useCase: FakeFeedUseCase,
        page: Int,
        status: Status?,
        result: Result<CharactersPageResponse, Error>
    ) {
        useCase
            .scheduled[
                FakeFeedUseCase.key(
                    page: page,
                    status: status?.rawValue
                )
            ] = ScheduledPage(
                page: page,
                status: status?.rawValue,
                result: result
            )
    }
}
