//
//  TabBarBuilder.swift
//  TabBarView
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import SwiftUI
import DependencyContainer
import DevPreview
import FeedView
import FeedListView
import CharacterDetailsView

@Observable
@MainActor
public final class TabBarBuilder {
    private let container: DIContainer

    public init(container: DIContainer) {
        self.container = container
    }

    public func buildTabBarView() -> some View {
        TabBarView()
    }
}

extension View {
    func previewEnvironment() -> some View {
        self
            .environment(
                TabBarBuilder(container: DevPreview.shared.container)
            )
            .environment(
                FeedBuilder(container: DevPreview.shared.container)
            )
            .environment(
                FeedListBuilder(container: DevPreview.shared.container)
            )
            .environment(
                CharacterDetailsBuilder(container: DevPreview.shared.container)
            )
    }
}
