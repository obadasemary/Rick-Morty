//
//  FeedView.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import DevPreview
import CharacterDetailsView
import UseCase

public struct FeedView: View {
    
    @State var viewModel: FeedViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(CharacterDetailsBuilder.self) private var characterDetailsBuilder
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    FiltersView() { filter in
                        viewModel
                            .filterByStatus(filter.map{ $0.toCharacterStatus })
                    }
                    
                    if let error = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text(error)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.red)
                            Button("Retry") {
                                viewModel.refreshData()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 24)
                    } else if viewModel.characters.isEmpty {
                        ProgressView()
                            .padding(.vertical, 24)
                    } else {
                        ForEach(viewModel.characters, id: \.id) { character in
                            NavigationLink {

                                let detailsAdapter = CharacterDetailsAdapter(
                                    id: character.id,
                                    name: character.name,
                                    status: character.status,
                                    species: character.species,
                                    gender: character.gender,
                                    image: character.image
                                )

                                characterDetailsBuilder
                                    .buildCharacterDetailsView(
                                        characterDetailsAdapter: detailsAdapter
                                    ) {
                                        dismiss()
                                    }
                            } label: {
                                CharacterView(character: character)
                            }
                            .onAppear {
                                // Infinite scroll trigger when the last item appears
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
        }
        .task {
            viewModel.loadInitialData()
        }
    }
}




#Preview {
    let container = DevPreview.shared.container
    let feedBuilder = FeedBuilder(container: container)
    feedBuilder.buildFeedView()
        .previewEnvironment()
}
