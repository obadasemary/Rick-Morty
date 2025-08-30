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
                delegate.feedBuilder.buildFeedView(router: router)
            }
            .environment(delegate.feedBuilder)
            .environment(delegate.characterDetailsBuilder)
        }
    }
}
