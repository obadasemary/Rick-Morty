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
    let composition = AppComposition()
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environment(composition)
                .environment(delegate.tabBarBuilder)
                .environment(delegate.feedBuilder)
                .environment(delegate.characterDetailsBuilder)
        }
    }
}
