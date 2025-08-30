//
//  RickMortyApp.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 27.08.2025.
//

import SwiftUI
import SUIRouting

@main
struct RickMortyApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RouterView { router in
                FeedViewControllerWrapper(
                    viewController: delegate.feedBuilder.buildFeedViewController(router: router)
                )
            }
            .environment(delegate.feedBuilder)
            .environment(delegate.characterDetailsBuilder)
        }
    }
}

struct FeedViewControllerWrapper: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}
