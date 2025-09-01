//
//  RickMortyApp.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 27.08.2025.
//

import SwiftUI
import TabBarView

@main
struct RickMortyApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environment(delegate.tabBarBuilder)
                .environment(delegate.feedBuilder)
                .environment(delegate.feedListBuilder)
                .environment(delegate.characterDetailsBuilder)
        }
    }
}
