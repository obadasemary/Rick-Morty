//
//  CharacterDetailsView.swift
//  CharacterDetailsView
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import SwiftUI
import UseCase
import DevPreview
import RickMortyUI

public struct CharacterDetailsView: View {
    
    @State var viewModel: CharacterDetailsViewModel
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .topLeading) {
                    CachedAsyncImage(url: viewModel.character.image) { image in
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
                    
                    if #available(iOS 26.0, *) {
                        
                    } else {
                        Button(
                            action: {
                                viewModel.back()
                            },
                            label: {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.primary, .background)
                                    .shadow(radius: 2)
                                    .frame(height: 35)
                            }
                        )
                        .accessibilityIdentifier("characterDetailsBackButton")
                        .accessibilityLabel("Back")
                        .padding(.leading, 16)
                        .padding(.top, 16)
                        .padding(
                            .top,
                            UIApplication
                                .shared
                                .connectedScenes
                                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                                .first?.safeAreaInsets.top ?? 0
                        )
                        .shadow(radius: 3)
                    }
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: .zero) {
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
                    
                    HStack(spacing: .zero) {
                        Text(viewModel.character.species)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text(" · ")
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text(viewModel.character.gender.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                
                if let location = viewModel.character.location {
                    HStack {
                        Text("Location :")
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text(location.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(UIColor.systemBackground))
        .navigationBarBackButtonHidden(shouldHideBackButton) // 👈 Hides the default back arrow
        .navigationBarHidden(shouldHideBackButton)
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
            Color.CharacterDetails.Status.Background.alive
        case .dead:
            Color.CharacterDetails.Status.Background.dead
        case .unknown:
            Color.CharacterDetails.Status.Background.unknown
        }
    }
    
    private var shouldHideBackButton: Bool {
        if #available(iOS 26.0, *) {
            return false
        } else {
            return true
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let characterDetailsBuilder = CharacterDetailsBuilder(container: container)
    
    characterDetailsBuilder
        .buildCharacterDetailsView(
            characterDetailsAdapter: CharacterAdapter.mock,
            backAction: {}
        )
        .previewEnvironment()
}
