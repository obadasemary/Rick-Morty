//
//  FiltersView.swift
//  FeedView
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import SwiftUI
import UseCase
import RickMortyUI

struct FiltersView: View {
    
    // MARK: - Properties
    let onFilterApplied: (Filter?) -> Void
    @State private var selectedStatus: Status?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                statusSection
                Spacer()
                actionButtons
            }
            .padding(24)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Status")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ForEach(Filter.allCases, id: \.self) { filter in
                    StatusFilterButton(
                        status: filter.toCharacterStatus,
                        isSelected: selectedStatus == filter.toCharacterStatus
                    ) {
                        if selectedStatus == filter.toCharacterStatus {
                            selectedStatus = nil
                        } else {
                            selectedStatus = filter.toCharacterStatus
                        }
                    }
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button("Apply Filters") {
                let filter = selectedStatus.flatMap { status in
                    Filter.allCases.first { $0.toCharacterStatus == status }
                }
                onFilterApplied(filter)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedStatus == nil)
            
            Button("Reset") {
                selectedStatus = nil
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Status Filter Button
struct StatusFilterButton: View {
    let status: Status
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(status.rawValue.capitalized)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? statusColor(for: status) : Color(UIColor.systemGray5))
                )
        }
        .buttonStyle(.plain)
    }
    
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
    FiltersView { filter in
        if let filter = filter {
            print("Filter applied: \(filter.toCharacterStatus.rawValue)")
        } else {
            print("No filter applied")
        }
    }
}
