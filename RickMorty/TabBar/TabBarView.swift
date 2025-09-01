//
//  TabBarView.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//


import SwiftUI
import FeedView
import CharacterDetailsView
import SUIRouting

struct TabBarView: View {
    
    @Environment(AppComposition.self) private var composition
    @Environment(FeedBuilder.self) private var feedBuilder
    @Environment(CharacterDetailsBuilder.self) private var characterDetailsBuilder
    
    var body: some View {
        TabView {
            RouterView { router in
                feedBuilder.buildFeedView(router: router)
            }
            .tabItem {
                Label("Explore", systemImage: "house")
            }
            
            RouterView { router in
                FeedListTabView(
                    viewModel: composition.makeFeedListViewModel(),
                    onSelect: { character in
                        router.showScreen(.push) { innerRouter in
                            characterDetailsBuilder
                                .buildCharacterDetailsView(
                                    characterDetailsAdapter: character,
                                    backAction: {
                                        innerRouter.dismissScreen()
                                    }
                                )
                        }
                    }
                )
            }
            .tabItem { Label("UIKit", systemImage: "list.bullet") }
        }
    }
}

#Preview {
    
    let composition = AppComposition()
    
    TabBarView()
        .environment(composition)
        .previewEnvironment()
}


