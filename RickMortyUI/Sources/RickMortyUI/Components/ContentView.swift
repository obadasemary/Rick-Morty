//
//  ContentView.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 11.09.2025.
//

import SwiftUI
import UseCase

public struct ContentView: View {
    
    let character: CharacterAdapter
    
    public init(character: CharacterAdapter) {
        self.character = character
    }
    
    public var body: some View {
        CustomList { progress in
            navBarView()
        } topContent: { progress, safeAreaTop in
            heroImage(progress, safeAreaTop: safeAreaTop)
        } header: { progress in
            headerView(progress)
        } content: {
            ScrollView {
                ForEach(1..<10) { _ in
                    VStack(spacing: .zero) {
                        HStack {
                            Text(character.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(statusText(character.status))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(statusColor(character.status))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 16)
                        
                        HStack(spacing: .zero) {
                            Text(character.species)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text(" · ")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text(character.gender.rawValue.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    if let location = character.location {
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
        }
    }
    
    /// Top Hero Image
    @ViewBuilder
    public func heroImage(_ progress: CGFloat, safeAreaTop: CGFloat) -> some View {
        GeometryReader {
            let minY = $0.frame(in: .global).minY - safeAreaTop
            let size = $0.size
            let height = size.height + (minY > 0 ? minY : 0)
            
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
                        .frame(width: size.width, height: height + safeAreaTop)
                        .offset(y: minY > 0 ? -minY : 0)
                        .offset(y: -safeAreaTop)
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
        }
        .frame(height: 250)
    }
    
    /// Custom Header View
    @ViewBuilder
    func headerView(_ progress: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rick and Morty")
                .font(.title2.bold())
                .frame(minHeight: 35)
                .offset(x: min(progress * 1.1, 1) * 60)
            
            let opacity = max(0, 1 - (progress * 1.5))
            let currentMenuTitleOpacity = max(progress - 0.9, 0) * 10
            
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.caption)
                
                Text("4.5 **(20K ratings)**")
                    .font(.callout)
                
                Image(systemName: "clock")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.leading, 10)
                
                Text("35-40 **Mins**")
                    .font(.callout)
            }
            .opacity(opacity)
            .overlay(alignment: .leading) {
                Text("Watch Again")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .fontWeight(.medium)
                    .contentTransition(.numericText())
                    .offset(x: 45, y: -5)
                    .opacity(currentMenuTitleOpacity)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            let backgroundProgress = max(progress - 0.8, 0) * 5
            
            Rectangle()
                .fill(.background)
                .padding(.top, backgroundProgress * -100)
                .shadow(
                    color: .gray.opacity(backgroundProgress * 0.3),
                    radius: 5,
                    x: 0,
                    y: 2
                )
        }
    }
    
    /// Nav Bar View
    @ViewBuilder
    func navBarView() -> some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.primary, .background)
                    .shadow(radius: 2)
                    .frame(height: 35)
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.primary, .background)
                    .shadow(radius: 2)
                    .frame(height: 35)
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
    }
    
    private enum Constants {
        static let imageDimension: CGFloat = 80
        static let cardCornerRadius: CGFloat = 12
        static let imageCornerRadius: CGFloat = 8
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
    ContentView(
        character: CharacterAdapter(
            id: 1,
            name: "Obada",
            status: .alive,
            species: "Human",
            gender: .male,
            location: "Earth",
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!,
        )
    )
}
