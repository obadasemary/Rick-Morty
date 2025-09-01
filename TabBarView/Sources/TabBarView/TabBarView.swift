//
//  TabBarView.swift
//  TabBarView
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import SwiftUI
import FeedView
import FeedListView
import CharacterDetailsView
import SUIRouting

public struct TabBarView: View {
    
    @Environment(FeedBuilder.self) private var feedBuilder
    @Environment(FeedListBuilder.self) private var feedListBuilder
    @Environment(CharacterDetailsBuilder.self) private var characterDetailsBuilder
    
    public init() {}
    
    public var body: some View {
        TabView {
            RouterView { router in
                feedBuilder.buildFeedView(router: router)
            }
            .tabItem {
                Label("SwiftUI", systemImage: "apple.terminal.fill")
            }
            
            RouterView { router in
                feedListBuilder
                    .buildFeedListViewController(router: router)
            }
            .tabItem {
                Label("UIKit", systemImage: "apple.terminal.on.rectangle.fill")
            }
        }
    }
}

#Preview {
    TabBarView()
        .previewEnvironment()
}


