//
//  AppDelegate.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 18.08.2025.
//

import UIKit
import TabBarView
import FeedView
import FeedListView
import CharacterDetailsView

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var composition: AppComposition?
    
    // Builders
    var tabBarBuilder: TabBarBuilder?
    var feedBuilder: FeedBuilder?
    var feedListBuilder: FeedListBuilder? // Hybrid UIKit/SwiftUI Architecture
    var characterDetailsBuilder: CharacterDetailsBuilder?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // Setup DI container
        let appComposition = AppComposition()
        
        // Check if composition was successful
        guard appComposition.isConfigured else {
            print("Failed to configure app dependencies")
            // You could show an error screen or handle this gracefully
            return false
        }
        
        composition = appComposition
        
        // Register builders safely
        tabBarBuilder = TabBarBuilder(container: appComposition.container)
        feedBuilder = FeedBuilder(container: appComposition.container)
        feedListBuilder = FeedListBuilder(container: appComposition.container)
        characterDetailsBuilder = CharacterDetailsBuilder(container: appComposition.container)
        
        return true
    }
}
