//
//  CachedAsyncImage.swift
//  RickMortyUI
//
//  Created by Claude Code on 12.11.2025.
//

import SwiftUI

/// A view that asynchronously loads and displays an image with caching support
///
/// This component provides the same API as SwiftUI's AsyncImage but adds
/// in-memory caching using NSCache to avoid redundant network requests.
///
/// Usage:
/// ```swift
/// CachedAsyncImage(url: characterURL) { phase in
///     switch phase {
///     case .empty:
///         ProgressView()
///     case .success(let image):
///         image.resizable()
///     case .failure:
///         Image(systemName: "photo")
///     @unknown default:
///         EmptyView()
///     }
/// }
/// ```
@MainActor
public struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content

    @State private var phase: AsyncImagePhase = .empty
    @State private var imageLoadTask: Task<Void, Never>?

    /// Creates a cached async image view with custom phase content
    /// - Parameters:
    ///   - url: The URL of the image to load
    ///   - scale: The scale to use for the image (default: 1.0)
    ///   - transaction: The transaction to use for phase changes
    ///   - content: A closure that returns the view to display for each phase
    public init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    public var body: some View {
        content(phase)
            .onAppear {
                loadImage()
            }
            .onChange(of: url) { _, _ in
                loadImage()
            }
            .onDisappear {
                cancelLoad()
            }
    }

    private func loadImage() {
        // Cancel any existing load task
        cancelLoad()

        guard let url = url else {
            updatePhase(.empty)
            return
        }

        // Check cache first
        if let cachedImage = ImageCache.shared.get(for: url) {
            updatePhase(.success(Image(uiImage: cachedImage)))
            return
        }

        // Start loading
        updatePhase(.empty)

        imageLoadTask = Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                // Check if task was cancelled
                guard !Task.isCancelled else { return }

                // Validate response
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    updatePhase(.failure(URLError(.badServerResponse)))
                    return
                }

                // Decode image
                guard let uiImage = UIImage(data: data, scale: scale) else {
                    updatePhase(.failure(URLError(.cannotDecodeContentData)))
                    return
                }

                // Cache the image
                ImageCache.shared.set(uiImage, for: url)

                // Update UI
                updatePhase(.success(Image(uiImage: uiImage)))

            } catch {
                // Only update phase if not cancelled
                guard !Task.isCancelled else { return }
                updatePhase(.failure(error))
            }
        }
    }

    private func cancelLoad() {
        imageLoadTask?.cancel()
        imageLoadTask = nil
    }

    private func updatePhase(_ newPhase: AsyncImagePhase) {
        withTransaction(transaction) {
            phase = newPhase
        }
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage {
    /// Creates a cached async image with a custom placeholder
    /// - Parameters:
    ///   - url: The URL of the image to load
    ///   - scale: The scale to use for the image (default: 1.0)
    ///   - content: A closure that returns the view for a successfully loaded image
    ///   - placeholder: A closure that returns the placeholder view
    public init<I: View, P: View>(
        url: URL?,
        scale: CGFloat = 1.0,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P> {
        self.init(url: url, scale: scale) { phase in
            if case .success(let image) = phase {
                content(image)
            } else {
                placeholder()
            }
        }
    }
}

// MARK: - Preview

#Preview("Cached Async Image") {
    VStack(spacing: 20) {
        // With phase handling
        CachedAsyncImage(
            url: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
        ) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 80, height: 80)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            case .failure:
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }

        // With placeholder
        CachedAsyncImage(
            url: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")
        ) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Color.gray.opacity(0.3)
        }
        .frame(width: 100, height: 100)
        .cornerRadius(8)
    }
    .padding()
}
