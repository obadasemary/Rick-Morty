//
//  CharacterView.swift
//  RickMortyUI
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import SwiftUI
import UseCase

public struct CharacterView: View {
    
    let character: CharacterAdapter
    
    public init(character: CharacterAdapter) {
        self.character = character
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: character.image) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(
                            width: Constants.imageDimension,
                            height: Constants.imageDimension
                        )
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: Constants.imageDimension,
                            height: Constants.imageDimension
                        )
                        .cornerRadius(Constants.imageCornerRadius)
                case .failure:
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: Constants.imageDimension,
                            height: Constants.imageDimension
                        )
                        .cornerRadius(Constants.imageCornerRadius)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                Text(character.species)
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(Constants.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var backgroundColor: Color {
        switch character.status {
        case .alive:
            Color.CaracterCard.Status.alive
        case .dead:
            Color.CaracterCard.Status.dead
        case .unknown:
            Color.CaracterCard.Status.unknown
        }
    }
    
    private var borderColor: Color {
        switch character.status {
        case .alive:
            Color.CaracterCard.Border.alive
        case .dead:
            Color.CaracterCard.Border.dead
        case .unknown:
            Color.CaracterCard.Border.unknown
        }
    }
    
    private enum Constants {
        static let imageDimension: CGFloat = 80
        static let cardCornerRadius: CGFloat = 12
        static let imageCornerRadius: CGFloat = 8
    }
}

#Preview {
    CharacterView(
        character: CharacterAdapter(
            id: 1,
            name: "Obada",
            status: .alive,
            species: "Human",
            gender: .male,
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!,
        )
    )
}
