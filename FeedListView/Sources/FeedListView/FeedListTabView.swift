//
//  FeedListTabView.swift
//  FeedListView
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import UIKit
import SwiftUI
import UseCase

public struct FeedListTabView: UIViewControllerRepresentable {
    
    let viewModel: FeedListViewModel

    public func makeUIViewController(context: Context) -> UINavigationController {
        let feedListViewController = FeedListViewController(
            viewModel: viewModel
        )
        let navigationController = UINavigationController(
            rootViewController: feedListViewController
        )
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }

    public func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {}
}
