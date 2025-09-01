//
//  FeedView.swift
//  FeedView
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import RickMortyUI
import DevPreview
import UseCase

struct FeedView: View {
    
    @State var viewModel: FeedViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                FiltersView { filter in
                    viewModel
                        .filterByStatus(filter.map{ $0.toCharacterStatus })
                }
                
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                        .padding(.vertical, 24)
                case .error:
                    VStack(spacing: 12) {
                        Text(viewModel.errorMessage ?? "An error occurred")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.red)
                        Button("Retry") {
                            viewModel.refreshData()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 24)
                case .loaded, .loadingMore:
                    ForEach(viewModel.characters, id: \.id) { character in
                        CharacterView(character: character)
                            .onTapGesture {
                                let detailsAdapter = CharacterAdapter(
                                    id: character.id,
                                    name: character.name,
                                    status: character.status,
                                    species: character.species,
                                    gender: character.gender,
                                    image: character.image
                                )
                                
                                viewModel
                                    .openCharacterDetail(for: detailsAdapter)
                            }
                            .onAppear {
                                if character.id == viewModel.characters.last?.id {
                                    viewModel.loadMoreData()
                                }
                            }
                    }
                    
                    if viewModel.isLoadingMore {
                        ProgressView()
                            .padding(.vertical, 16)
                    }
                }
            }
        }
        .refreshable {
            viewModel.refreshData()
        }
        .navigationTitle("Characters")
        .task {
            viewModel.loadInitialData()
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let feedBuilder = FeedBuilder(container: container)
    
    return RouterView { router in
        feedBuilder.buildFeedView(router: router)
    }
    .previewEnvironment()
}
