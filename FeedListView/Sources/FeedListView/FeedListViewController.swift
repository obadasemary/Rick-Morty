//
//  FeedListViewController.swift
//  FeedListView
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import UIKit
import SwiftUI
import UseCase
import Observation
import RickMortyUI

class FeedListViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    enum Section {
        case main
    }
    
    private let viewModel: FeedListViewModel
    
    private static let cellIdentifier = "CharacterCell"
    private var dataSource: UITableViewDiffableDataSource<Section, CharacterAdapter>!
    
    init(viewModel: FeedListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Rick and Morty UIKit"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .always
        
        startObservingViewModel()
        
        tableView.prefetchDataSource = self
        tableView
            .register(
                CharacterTableViewCell.self,
                forCellReuseIdentifier: FeedListViewController.cellIdentifier
            )
        tableView.separatorStyle = .none
        
        setupPullToRefresh()
        
        dataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, characterAdapter in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: FeedListViewController.cellIdentifier,
                    for: indexPath
                ) as! CharacterTableViewCell
                
                cell.selectionStyle = .none
                cell.set(character: characterAdapter, viewController: self)
                return cell
            }
        )
        
        renderState()
        viewModel.loadInitialData()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let filtersView = FiltersView() { [weak self] filter in
            self?.viewModel.applyFilter(filter: filter)
        }
        return UIHostingController(rootView: filtersView).view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(
        _ tableView: UITableView,
        prefetchRowsAt indexPaths: [IndexPath]
    ) {
        if indexPaths
            .contains(where: { $0.row >= viewModel.characters.count - 3 }) {
            viewModel.loadMoreData()
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if let characterAdapter = dataSource?.itemIdentifier(for: indexPath) {
            viewModel.openCharacterDetail(for: characterAdapter)
        }
    }
}

private extension FeedListViewController {
    
    func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(
            self,
            action: #selector(handlePullToRefresh),
            for: .valueChanged
        )
    }
    
    @objc func handlePullToRefresh() {
        viewModel.refreshData()
    }
    
    func startObservingViewModel() {
        withObservationTracking {
            // Read the properties you want to observe.
            _ = viewModel.state
            _ = viewModel.characters
            _ = viewModel.isLoadingMore
        } onChange: { [weak self] in
            // Re-render and re-establish tracking.
            Task { @MainActor in
                self?.renderState()
                self?.startObservingViewModel()
            }
        }
    }
    
    func renderState() {
        switch viewModel.state {
        case .idle, .loading:
            renderLoadingState()
        case .loaded(let characters):
            tableView.backgroundView = nil
            refreshControl?.endRefreshing()
            applyCharactersSnapshot(characters, scrollToTop: viewModel.currentPage == 1)
        case .loadingMore(let characters):
            tableView.backgroundView = nil
            applyCharactersSnapshot(characters, scrollToTop: false)
        case .error:
            refreshControl?.endRefreshing()
            renderErrorState(message: viewModel.errorMessage ?? "An error occurred")
        }
    }
    
    func applyCharactersSnapshot(
        _ characters: [CharacterAdapter],
        scrollToTop: Bool
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CharacterAdapter>()
        snapshot.appendSections([.main])
        snapshot.appendItems(characters, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: !scrollToTop) { [weak self] in
            guard scrollToTop, let self, !characters.isEmpty else { return }
            self.tableView.scrollToRow(
                at: IndexPath(row: 0, section: 0),
                at: .top,
                animated: false
            )
        }
    }
    
    func renderLoadingState() {
        self.tableView.backgroundView = UIHostingController(rootView: ProgressView()).view
    }
    
    func renderErrorState(message: String) {
        let errorView = ErrorView(message: message) { [weak self] in
            self?.viewModel.refreshData()
        }
        tableView.backgroundView = UIHostingController(rootView: errorView).view
    }
}
