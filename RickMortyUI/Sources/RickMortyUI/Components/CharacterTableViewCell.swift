#if canImport(UIKit)
//
//  CharacterTableViewCell.swift
//  RickMortyUI
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import UIKit
import SwiftUI
import UseCase

public class CharacterTableViewCell: UITableViewCell {
    
    private var hostingController: UIHostingController<CharacterView>?
    
    public func set(
        character: CharacterAdapter,
        viewController: UIViewController
    ) {
        
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        let characterHostingController = UIHostingController(rootView: CharacterView(character: character))
        characterHostingController.view.backgroundColor = .clear
        
        viewController.addChild(characterHostingController)
        contentView.addSubview(characterHostingController.view)
        
        characterHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                characterHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                characterHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                characterHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                characterHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ]
        )
        
        characterHostingController.didMove(toParent: viewController)
        hostingController = characterHostingController
    }
}
#else
import Foundation
/// Stub to allow SPM to build this target on non-UIKit platforms (e.g., macOS during dependency resolution).
public class CharacterTableViewCell: NSObject {}
#endif
