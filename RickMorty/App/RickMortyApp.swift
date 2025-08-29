//
//  RickMortyApp.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 27.08.2025.
//

import SwiftUI

@main
struct RickMortyApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            delegate.feedBuilder.buildFeedView()
                .environment(delegate.feedBuilder)
                .environment(delegate.characterDetailsBuilder)
        }
    }
}
