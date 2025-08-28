//
//  FeedView.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import DevPreview

public struct FeedView: View {
    
    @State var viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    if let characters = viewModel.characters {
                        ForEach(characters.results, id: \.id) { character in
                            CharacterView(character: character)
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
