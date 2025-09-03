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
                    AsyncImage(url: viewModel.character.image) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(
                        width: 400,
                        height: 400
                    )
                    .clipped()
                    .cornerRadius(20)
                    
                    Button(
                        action: {
                            viewModel.back()
                        },
                        label: {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                        }
                    )
                    .padding(.leading, 16)
                    .padding(.top, 16)
                    .padding(.top, 20)
                    .shadow(radius: 3)
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
                            .foregroundColor(.black)
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
                            .foregroundColor(.black)
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
        .background(Color(.systemBackground))
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
            characterDetailsAdapter: CharacterAdapter.mock,
            backAction: {}
        )
        .previewEnvironment()
}
