//
//  TabBarBuilder.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//


import SwiftUI
import DependencyContainer
import DevPreview
import FeedView
import CharacterDetailsView

@Observable
@MainActor
final class TabBarBuilder {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func buildTabBarView() -> some View {
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
                CharacterDetailsBuilder(container: DevPreview.shared.container)
            )
    }
}
