//
//  FeedViewModel.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation
import UseCase
import RickMortyNetworkLayer
import CharacterDetailsView

@Observable
@MainActor
final class FeedViewModel {
    // MARK: - State
    enum State {
        case idle
        case loading
//        case loaded([CharacterResponse])
        case loaded([CharacterAdapter])
        case error(Error)
//        case loadingMore([CharacterResponse])
        case loadingMore([CharacterAdapter])
    }

    // MARK: - Published Properties
//    private(set) var characters: [CharacterResponse] = []
    private(set) var characters: [CharacterAdapter] = []
    private(set) var currentPage: Int = 1
    private(set) var hasMorePages: Bool = true
    private(set) var selectedStatus: Status? = nil
    private(set) var state: State = .idle

    // Loading guard
    private var isLoading: Bool = false

    // MARK: - Dependencies
    private let feedUseCase: FeedUseCaseProtocol
    private let router: FeedRouterProtocol

    // MARK: - Initialization
    init(
        feedUseCase: FeedUseCaseProtocol,
        router: FeedRouterProtocol
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
        guard hasMorePages && !isLoading else { return }
        Task { [weak self] in
            guard let self else { return }
            await self.fetchCharacters(page: self.currentPage + 1, status: self.selectedStatus)
        }
    }

    func filterByStatus(_ status: Status?) {
        selectedStatus = status
        currentPage = 1
        hasMorePages = true
        characters = []
        state = .loading
        Task { [weak self] in
            await self?.fetchCharacters(page: 1, status: status)
        }
    }

    func openCharacterDetail(for character: CharacterDetailsAdapter) {
        router.showCharacterDetails(characterDetailsAdapter: character)
    }
}

// MARK: - Private Methods
private extension FeedViewModel {
 
    func fetchCharacters(page: Int, status: Status?) async {
        guard !isLoading else { return }
        isLoading = true

        if page == 1 {
            state = .loading
        } else {
            state = .loadingMore(characters)
        }

        do {
            let response = try await feedUseCase.execute(page: page, status: status?.rawValue)

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
                state = .error(error)
            } else {
                // Keep existing data on pagination error
                state = .loaded(characters)
            }
        }

        isLoading = false
    }
}

// MARK: - Error Handling
extension FeedViewModel {
    var errorMessage: String? {
        guard case .error(let error) = state else { return nil }

        if let networkError = error as? NetworkError {
            switch networkError {
            case .networkError:
                return "Network connection error. Please check your internet connection."
            case .serverError(let statusCode):
                return "Server error (Status: \(statusCode)). Please try again later."
            case .decodingError:
                return "Data format error. Please try again."
            case .invalidURL, .invalidResponse:
                return "Invalid response from server. Please try again."
            }
        }

        return error.localizedDescription
    }

    var isLoadingMore: Bool {
        guard case .loadingMore = state else { return false }
        return true
    }
}
