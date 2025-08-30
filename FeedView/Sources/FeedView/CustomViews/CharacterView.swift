//
//  CharacterView.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI

private enum Constants {
    static let imageDimension: CGFloat = 80
    static let cardCornerRadius: CGFloat = 12
    static let imageCornerRadius: CGFloat = 8
}

struct CharacterView: View {
    
    let character: CharacterAdapter
    
    var body: some View {
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
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
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
