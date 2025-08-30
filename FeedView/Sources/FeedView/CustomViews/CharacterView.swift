//
//  CharacterView.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import SwiftUI
import UseCase
import RickMortyUI

struct CharacterView: View {
    
    // MARK: - Properties
    let character: CharacterAdapter
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 16) {
            // Character Image
            AsyncImage(url: character.image) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                @unknown default:
                    EmptyView()
                }
            }
            
            // Character Info
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text(character.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Species
                Text(character.species)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Status Badge
                HStack {
                    Circle()
                        .fill(statusColor(for: character.status))
                        .frame(width: 8, height: 8)
                    
                    Text(character.status.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Methods
    private func statusColor(for status: Status) -> Color {
        switch status {
        case .alive:
            return .green
        case .dead:
            return .red
        case .unknown:
            return .gray
        }
    }
}

// MARK: - Preview
#Preview {
    CharacterView(character: CharacterAdapter(
        id: 1,
        name: "Rick Sanchez",
        status: .alive,
        species: "Human",
        gender: .male,
        image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
    ))
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}


