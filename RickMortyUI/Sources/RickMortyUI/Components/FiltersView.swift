//
//  FiltersView.swift
//  RickMortyUI
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import SwiftUI
import UseCase

public struct FiltersView: View {
    
    @State private var selectedFilter: FilterAdapter?
    public var onFilterChanged: ((FilterAdapter?) -> Void)?
    
    public init(
        onFilterChanged: ((FilterAdapter?) -> Void)? = nil
    ) {
        self.onFilterChanged = onFilterChanged
    }
    
    public var body: some View {
        HStack {
            HStack(spacing: 12) {
                ForEach(FilterAdapter.allCases, id: \.self) { filter in
                    Text(title(for: filter))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .clipShape(Capsule())
                        .accessibilityIdentifier(accessibilityIdentifier(for: filter))
                        .accessibilityAddTraits(.isButton)
                        .onTapGesture {
                            if selectedFilter == filter {
                                selectedFilter = nil
                            } else {
                                selectedFilter = filter
                            }
                            onFilterChanged?(selectedFilter)
                        }
                }
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
    
    private func title(for filter: FilterAdapter) -> String {
        switch filter {
        case .alive: return "Alive"
        case .dead: return "Dead"
        case .unknown: return "Unknown"
        }
    }

    private func accessibilityIdentifier(for filter: FilterAdapter) -> String {
        switch filter {
        case .alive: return "filterAlive"
        case .dead: return "filterDead"
        case .unknown: return "filterUnknown"
        }
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView()
    }
}
