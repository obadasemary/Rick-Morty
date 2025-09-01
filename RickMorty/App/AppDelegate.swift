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
    
    var composition: AppComposition!
    
    // Builders
    var tabBarBuilder: TabBarBuilder!
    var feedBuilder: FeedBuilder!
    var feedListBuilder: FeedListBuilder!
    var characterDetailsBuilder: CharacterDetailsBuilder!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // Setup DI container
        composition = AppComposition()
        
        // Register builders
        tabBarBuilder = TabBarBuilder(container: composition.container)
        feedBuilder = FeedBuilder(container: composition.container)
        feedListBuilder = FeedListBuilder(container: composition.container)
        characterDetailsBuilder = CharacterDetailsBuilder(container: composition.container)
        
        return true
    }
}
