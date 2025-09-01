//
//  FeedListViewModel.swift
//  FeedListView
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import UseCase
import SUIRouting

@MainActor
final class FeedListViewModel {
    
    enum State: Equatable {
        case loading
        case loaded([CharacterAdapter], isFirstPage: Bool)
        case error(message: String)
    }
    
    private let feedUseCase: FeedUseCaseProtocol
    private let router: FeedListRouterProtocol
    
    private(set) var selectedStatus: Status? = nil
    
    private(set) var state: State = .loading {
        didSet {
            stateDidChange?()
        }
    }
    
    private var filter: FilterAdapter?
    var stateDidChange: (() -> Void)?
    
    private var page = 1
    
    init(
        feedUseCase: FeedUseCaseProtocol,
        router: FeedListRouterProtocol
    ) {
        self.feedUseCase = feedUseCase
        self.router = router
    }
    
    func didLoad() {
        Task { await loadCharacters() }
    }
    
    func loadMore() {
        page += 1
        Task { await loadCharacters() }
    }
    
    func applyFilter(filter: FilterAdapter?) {
        selectedStatus = filter?.toCharacterStatus
        page = 1
        Task { await loadCharacters() }
    }
    
    func retry() {
        state = .loading
        Task { await loadCharacters() }
    }
    
    func openCharacterDetail(for character: CharacterAdapter) {
        router.showCharacterDetails(characterDetailsAdapter: character)
    }
}

private extension FeedListViewModel {
    
    func loadCharacters() async {
        do {
            let response = try await feedUseCase
                .execute(
                    page: page,
                    status: selectedStatus?.rawValue
                )
            
            if page == 1 {
                state =
                    .loaded(
                        response.results.map { $0.toAdapter() },
                        isFirstPage: true
                    )
            } else {
                guard case let .loaded(oldCharacters, _) = state else { return }
                var newCharacters = oldCharacters
                newCharacters.append(contentsOf: response.results.map { $0.toAdapter() })
                state = .loaded(newCharacters, isFirstPage: false)
            }
        } catch {
            state = .error(message: "Something Went Wrong")
        }
    }
}

extension FeedListViewModel.State {
    var charactersAdapter: [CharacterAdapter] {
        switch self {
        case let .loaded(characters, _):
            characters
        case .error, .loading:
            []
        }
    }
}
