//
//  FeedView.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import DevPreview
import CharacterDetailsView

public struct FeedView: View {
    
    @State var viewModel: FeedViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(CharacterDetailsBuilder.self) private var characterDetailsBuilder
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    FiltersView() { filter in
//                      self?.viewModel.applyFilter(filter: filter)
                    }
                    
                    if let characters = viewModel.characters {
                        ForEach(characters.results, id: \.id) { character in
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
                                CharacterView(character: character.toAdapter())
                            }
//                            CharacterView(character: character.toAdapter())
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
            .navigationTitle("Characters")
        }
        .task {
            await viewModel.fetchCharacters()
        }
    }
}



#Preview {
    let container = DevPreview.shared.container
    let feedBuilder = FeedBuilder(container: container)
    feedBuilder.buildFeedView()
        .previewEnvironment()
}
