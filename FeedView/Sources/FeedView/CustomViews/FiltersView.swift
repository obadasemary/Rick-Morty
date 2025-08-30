//
//  FiltersView.swift
//  FeedView
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import SwiftUI

struct FiltersView: View {
    
    @State private var selectedFilter: Filter?
    var onFilterChanged: ((Filter?) -> Void)?
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                ForEach(Filter.allCases, id: \.self) { filter in
                    Text(title(for: filter))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .clipShape(Capsule())
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
    
    private func title(for filter: Filter) -> String {
        switch filter {
        case .alive: return "Alive"
        case .dead: return "Dead"
        case .unknown: return "Unknown"
        }
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView()
    }
}
