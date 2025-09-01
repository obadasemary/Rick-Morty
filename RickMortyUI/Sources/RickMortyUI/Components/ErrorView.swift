//
//  ErrorView.swift
//  RickMortyUI
//
//  Created by Abdelrahman Mohamed on 01.09.2025.
//

import SwiftUI

public struct ErrorView: View {
    
    let message: String
    let onRetry: () -> Void
    
    public init(message: String, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: onRetry) {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(message: "Something went wrong", onRetry: {})
}
