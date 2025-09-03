//
//  CharacterTableViewCell.swift
//  RickMortyUI
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

#if os(iOS)
import UIKit
#endif
import SwiftUI
import UseCase

#if os(iOS)
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
#endif
