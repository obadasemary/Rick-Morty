//
//  ImageCache.swift
//  RickMortyUI
//
//  Created by Claude Code on 12.11.2025.
//

import UIKit
import SwiftUI

/// Thread-safe image cache using NSCache for automatic memory management
@MainActor
public final class ImageCache {

    /// Shared singleton instance
    public static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    nonisolated(unsafe) private var memoryWarningObserver: NSObjectProtocol?

    private init() {
        // Configure cache limits
        cache.countLimit = 100 // Maximum 100 images
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB

        // Clear cache on memory warning using block-based observer for MainActor compatibility
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.clearCache()
            }
        }
    }

    deinit {
        if let observer = memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// Retrieves an image from cache
    /// - Parameter url: The URL key for the cached image
    /// - Returns: The cached UIImage if available, nil otherwise
    public func get(for url: URL) -> UIImage? {
        cache.object(forKey: url.absoluteString as NSString)
    }

    /// Stores an image in the cache
    /// - Parameters:
    ///   - image: The UIImage to cache
    ///   - url: The URL key for storing the image
    public func set(_ image: UIImage, for url: URL) {
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        cache.setObject(image, forKey: url.absoluteString as NSString, cost: cost)
    }

    /// Clears all cached images
    public func clearCache() {
        cache.removeAllObjects()
    }

    /// Removes a specific image from cache
    /// - Parameter url: The URL key for the image to remove
    public func remove(for url: URL) {
        cache.removeObject(forKey: url.absoluteString as NSString)
    }
}
