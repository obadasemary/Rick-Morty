import UIKit
import SwiftUI
import UseCase
import RickMortyUI
import CharacterDetailsView

@MainActor
final class FeedViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: FeedViewModel
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Initialization
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Characters"
        view.backgroundColor = .systemBackground
        
        // Add filters button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(showFilters)
        )
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // TableView configuration
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: "CharacterCell")
        
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupBindings() {
        // Observe state changes using @Observable
        // We'll handle state changes in the view lifecycle methods
        observeStateChanges()
    }
    
    private func observeStateChanges() {
        // With @Observable, we'll handle state changes manually
        // by calling handleStateChange when needed
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        viewModel.loadInitialData()
        handleStateChange(viewModel.state)
    }
    
    @objc private func refreshData() {
        viewModel.refreshData()
        handleStateChange(viewModel.state)
    }
    
    @objc private func showFilters() {
        let filtersView = FiltersView { filter in
            if let filter = filter {
                self.viewModel.filterByStatus(filter.toCharacterStatus)
            } else {
                self.viewModel.filterByStatus(nil)
            }
            self.handleStateChange(self.viewModel.state)
        }
        let hostingController = UIHostingController(rootView: filtersView)
        let navController = UINavigationController(rootViewController: hostingController)
        present(navController, animated: true)
    }
    
    // MARK: - State Handling
    private func handleStateChange(_ state: FeedViewModel.State) {
        switch state {
        case .idle:
            break
            
        case .loading:
            // Show loading state
            break
            
        case .loaded(_):
            refreshControl.endRefreshing()
            tableView.reloadData()
            
        case .loadingMore(_):
            // Update existing data without full reload
            tableView.reloadData()
            
        case .error:
            refreshControl.endRefreshing()
            // Show error state
            break
        }
    }
}

// MARK: - UITableViewDataSource
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as! CharacterTableViewCell
        let character = viewModel.characters[indexPath.row]
        cell.configure(with: character)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let character = viewModel.characters[indexPath.row]
        let detailsAdapter = CharacterDetailsAdapter(
            id: character.id,
            name: character.name,
            status: character.status,
            species: character.species,
            gender: character.gender,
            image: character.image
        )
        
        viewModel.openCharacterDetail(for: detailsAdapter)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Infinite scroll trigger when the last item appears
        if indexPath.row == viewModel.characters.count - 1 {
            viewModel.loadMoreData()
        }
    }
}
