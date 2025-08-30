import UIKit
import SwiftUI
import UseCase
import RickMortyUI

final class CharacterTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    private var hostingController: UIHostingController<CharacterView>?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
    }
    
    // MARK: - Configuration
    func configure(with character: CharacterAdapter) {
        // Remove existing hosting controller if any
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        // Create SwiftUI view
        let characterView = CharacterView(character: character)
        
        // Create hosting controller
        let hostingController = UIHostingController(rootView: characterView)
        hostingController.view.backgroundColor = .clear
        
        // Add to cell
        contentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Store reference
        self.hostingController = hostingController
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        hostingController = nil
    }
}
