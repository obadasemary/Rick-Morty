//
//  CustomList.swift
//  RickMorty
//
//  Created by Abdelrahman Mohamed on 11.09.2025.
//

import SwiftUI
import UseCase

@MainActor
public struct CustomList<NavBar: View, TopContent: View, Header: View, Content: View>: View {
    
    @ViewBuilder var navBar: (_ progress: CGFloat) -> NavBar
    @ViewBuilder var topContent: (_ progress: CGFloat, _ safeAreaTop: CGFloat) -> TopContent
    @ViewBuilder var header: (_ progress: CGFloat) -> Header
    @ViewBuilder var content: Content
    
    @State private var headerProgress: CGFloat = 0
    @State private var safeAreaTop: CGFloat = 0
    @State private var topContentHeight: CGFloat = 0
    
    @Environment(\.colorScheme) var colorScheme
    
    public var body: some View {
        List {
            topContent(headerProgress, safeAreaTop)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { @MainActor newValue in
                    topContentHeight = newValue
                }
                .customListRow()

            Section {
                content
            } header: {
                header(headerProgress)
                    .foregroundStyle(foregroundColor)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy
                            .frame(in: .named("customListCoordinateSpace")).maxY
                    } action: { @MainActor newValue in
                        guard topContentHeight != .zero else { return }
                        
                        let progress = (
                            newValue - safeAreaTop
                        ) / topContentHeight
                        let cappedProgress = 1 - max(min(progress, 1), 0)
                        self.headerProgress = cappedProgress
                        print(cappedProgress)
                    }
                    .customListRow()
            }
        }
        .listStyle(.plain)
        .listRowSpacing(0)
        .listSectionSpacing(0)
        .overlay(alignment: .top) {
            navBar(headerProgress)
        }
        .coordinateSpace(name: "customListCoordinateSpace")
        .onGeometryChange(for: CGFloat.self) {
            $0.safeAreaInsets.top
        } action: { @MainActor newValue in
            safeAreaTop = newValue
        }
    }
    
    var foregroundColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

extension View {
    @ViewBuilder
    func customListRow(top: CGFloat = 0, bottom: CGFloat = 0) -> some View {
        self
            .listRowInsets(
                .init(top: top, leading: 0, bottom: bottom, trailing: 0)
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
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
