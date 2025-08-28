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

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var composition: AppComposition!
    
    // Builders
    var feedBuilder: FeedBuilder!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // Setup DI container
        composition = AppComposition()
        
        // Register builders
        feedBuilder = FeedBuilder(container: composition.container)
        
        return true
    }
}
