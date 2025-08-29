//
//  CharacterDetailsView.swift
//  CharacterDetailsView
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import SwiftUI
import UseCase
import DevPreview

public struct CharacterDetailsView: View {
    
    @State var viewModel: CharacterDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: viewModel.character.image) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.width
                    )
                    .clipped()
                    .cornerRadius(20)
                    
                    // Back button overlay
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)
                    .padding(.top, UIApplication.shared.connectedScenes
                        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                        .first?.safeAreaInsets.top ?? 0
                    )
                    .shadow(radius: 3)
                }
                .frame(maxWidth: .infinity)
                
                // Name
                HStack {
                    Text(viewModel.character.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(statusText(viewModel.character.status))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor(viewModel.character.status))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                
                HStack {
                    Text(
                        "\(viewModel.character.species) · \(viewModel.character.gender.rawValue.capitalized)"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(UIColor.systemBackground))
        .navigationBarBackButtonHidden(true) // 👈 Hides the default back arrow
        .navigationBarHidden(true)
    }
    
    private func statusText(_ status: UseCase.Status) -> String {
        switch status {
        case .alive:
            "Alive"
        case .dead:
            "Dead"
        case .unknown:
            "Unknown"
        }
    }
    
    private func statusColor(_ status: UseCase.Status) -> Color {
        switch status {
        case .alive:
            Color.CaracterDetails.Status.Background.alive
        case .dead:
            Color.CaracterDetails.Status.Background.dead
        case .unknown:
            Color.CaracterDetails.Status.Background.unknown
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let characterDetailsBuilder = CharacterDetailsBuilder(container: container)
    
    characterDetailsBuilder
        .buildCharacterDetailsView(
            characterDetailsAdapter: CharacterDetailsAdapter.mock,
            backAction: {}
        )
        .previewEnvironment()
}

extension Color {
    static var lightBlue: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.25, blue: 0.35, alpha: 1)
            : UIColor(red: 0.85, green: 0.93, blue: 1.0, alpha: 1)
        })
    }
    
    static var lightRed: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.25, green: 0.15, blue: 0.15, alpha: 1)
            : UIColor(red: 1.0, green: 0.90, blue: 0.90, alpha: 1)
        })
    }
    
    static let lightGray = Color.gray.opacity(0.3)
}


extension Color {
    enum CaracterCard {
        enum Status {
            static let alive = Color.lightBlue
            static let dead = Color.lightRed
            static let unknown = Color(.systemBackground)
        }
        
        enum Border {
            static let alive = Color.lightBlue
            static let dead = Color.lightRed
            static let unknown = Color.lightGray
        }
    }
    
    enum CaracterDetails {
        enum Status {
            enum Background {
                static let alive = Color.lightBlue
                static let dead = Color.lightRed
                static let unknown = Color.lightGray
            }
        }
    }
}
