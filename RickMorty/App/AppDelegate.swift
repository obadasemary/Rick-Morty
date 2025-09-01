//
//  AppDelegate.swift
//  ThmanyahChallenges
//
//  Created by Abdelrahman Mohamed on 18.08.2025.
//

import Foundation
import UIKit
import RickMortyNetworkLayer
import CoreAPI
import RickMortyRepository
import UseCase
import FeedView
import CharacterDetailsView

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var composition: AppComposition!
    
    // Builders
    var tabBarBuilder: TabBarBuilder!
    var feedBuilder: FeedBuilder!
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
        characterDetailsBuilder = CharacterDetailsBuilder(container: composition.container)
        
        return true
    }
}
