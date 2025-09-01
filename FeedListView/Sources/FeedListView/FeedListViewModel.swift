//
//  FeedListViewModel.swift
//  FeedListView
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import Foundation
import UseCase

@Observable
@MainActor
final class FeedListViewModel {
    
    // MARK: - State
    enum State {
        case idle
        case loading
        case loaded([CharacterAdapter])
        case error(FeedError)
        case loadingMore([CharacterAdapter])
    }
    
    // MARK: - Dependencies
    private let feedUseCase: FeedUseCaseProtocol
    private let router: FeedListRouterProtocol
    
    // MARK: - Published Properties
    private(set) var characters: [CharacterAdapter] = []
    private(set) var currentPage: Int = 1
    private(set) var hasMorePages: Bool = true
    private(set) var selectedStatus: Status? = nil
    private(set) var state: State = .idle
    
    // Loading guard
    private var isLoading: Bool = false
    
    // MARK: - Initialization
    init(
        feedUseCase: FeedUseCaseProtocol,
        router: FeedListRouterProtocol
    ) {
        self.feedUseCase = feedUseCase
        self.router = router
    }
    
    // MARK: - Public Methods
    func loadInitialData() {
        guard case .idle = state else { return }
        Task { [weak self] in
            await self?.fetchCharacters(page: 1, status: self?.selectedStatus)
        }
    }
    
    func refreshData() {
        currentPage = 1
        hasMorePages = true
        characters = []
        state = .loading
        Task { [weak self] in
            await self?.fetchCharacters(page: 1, status: self?.selectedStatus)
        }
    }
    
    func loadMoreData() {
        print("loadMore? page = \(currentPage) hasMore = \(hasMorePages) isLoading = \(isLoading)")
        guard hasMorePages && !isLoading else { return }
        Task { [weak self] in
            guard let self else { return }
            await self.fetchCharacters(page: self.currentPage + 1, status: self.selectedStatus)
        }
    }
    
    func applyFilter(filter: FilterAdapter?) {
        selectedStatus = filter?.toCharacterStatus
        currentPage = 1
        hasMorePages = true
        characters = []
        state = .loading
        Task { [weak self] in
            guard let self else { return }
            await self.fetchCharacters(page: 1, status: self.selectedStatus)
        }
    }
    
    func retry() {
        refreshData()
    }
    
    func openCharacterDetail(for character: CharacterAdapter) {
        router.showCharacterDetails(characterDetailsAdapter: character)
    }
}

// MARK: - Private Methods
private extension FeedListViewModel {
    
    func fetchCharacters(page: Int, status: Status?) async {
        guard !isLoading else { return }
        isLoading = true

        if page == 1 {
            state = .loading
        } else {
            state = .loadingMore(characters)
        }

        do {
            let response = try await feedUseCase
                .execute(
                    page: page,
                    status: status?.rawValue
                )

            if page == 1 {
                characters = response.results.map { $0.toAdapter() }
            } else {
                characters.append(contentsOf: response.results.map { $0.toAdapter() })
            }

            currentPage = page
            hasMorePages = response.info.next != nil
            state = .loaded(characters)
        } catch {
            if page == 1 {
                state = .error(mapError(error))
            } else {
                // Keep existing data on pagination error
                state = .loaded(characters)
            }
        }

        isLoading = false
    }
}

// MARK: - Error Handling
extension FeedListViewModel {
    
    func mapError(_ error: Error) -> FeedError {
        // Network connectivity
        if error is URLError { return .network }
        // JSON decoding / parsing
        if error is DecodingError { return .decoding }
        
        let nsError = error as NSError
        // Try to extract an HTTP status code if upstream attached it
        if let status = nsError.userInfo["HTTPStatusCode"] as? Int {
            return .server(status: status)
        }
        
        // If we can’t classify it, surface a safe message
        if let desc = (error as? LocalizedError)?.errorDescription, !desc.isEmpty {
            return .unknown(message: desc)
        }
        return .unknown(message: nsError.localizedDescription)
    }
    
    var errorMessage: String? {
        guard case .error(let error) = state else { return nil }
        switch error {
        case .network:
            return "Network connection error. Please check your internet connection."
        case .server(let status):
            if let status { return "Server error (Status: \(status)). Please try again later." }
            return "Server error. Please try again later."
        case .decoding:
            return "Data format error. Please try again."
        case .invalidResponse:
            return "Invalid response from server. Please try again."
        case .unknown(let message):
            return message
        }
    }

    var isLoadingMore: Bool {
        guard case .loadingMore = state else { return false }
        return true
    }
}
