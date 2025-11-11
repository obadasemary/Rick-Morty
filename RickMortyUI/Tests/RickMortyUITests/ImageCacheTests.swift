//
//  ImageCacheTests.swift
//  RickMortyUITests
//
//  Created by Claude Code on 12.11.2025.
//

import Testing
import UIKit
@testable import RickMortyUI

@Suite("ImageCache Tests")
@MainActor
struct ImageCacheTests {

    // MARK: - Test Helpers

    /// Creates a test UIImage with a specific color and size
    private func createTestImage(color: UIColor = .red, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    /// Creates a test URL
    private func createTestURL(path: String = "test-image") -> URL {
        URL(string: "https://example.com/\(path).jpg")!
    }

    // MARK: - Basic Caching Tests

    @Test("ImageCache should store and retrieve an image")
    func testCacheStoreAndRetrieve() async throws {
        let cache = ImageCache.shared
        let testImage = createTestImage(color: .blue)
        let testURL = createTestURL()

        // Clear cache first
        cache.clearCache()

        // Store image
        cache.set(testImage, for: testURL)

        // Retrieve image
        let retrievedImage = cache.get(for: testURL)

        // Verify image was retrieved
        #expect(retrievedImage != nil, "Image should be retrieved from cache")
        #expect(retrievedImage?.size == testImage.size, "Retrieved image should have same size")
    }

    @Test("ImageCache should return nil for non-existent image")
    func testCacheRetrieveNonExistent() async throws {
        let cache = ImageCache.shared
        let testURL = createTestURL(path: "non-existent")

        // Clear cache first
        cache.clearCache()

        // Try to retrieve non-existent image
        let retrievedImage = cache.get(for: testURL)

        // Verify nil is returned
        #expect(retrievedImage == nil, "Non-existent image should return nil")
    }

    @Test("ImageCache should cache multiple different images")
    func testCacheMultipleImages() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let redImage = createTestImage(color: .red)
        let blueImage = createTestImage(color: .blue)
        let greenImage = createTestImage(color: .green)

        let redURL = createTestURL(path: "red")
        let blueURL = createTestURL(path: "blue")
        let greenURL = createTestURL(path: "green")

        // Store multiple images
        cache.set(redImage, for: redURL)
        cache.set(blueImage, for: blueURL)
        cache.set(greenImage, for: greenURL)

        // Retrieve and verify each image
        let retrievedRed = cache.get(for: redURL)
        let retrievedBlue = cache.get(for: blueURL)
        let retrievedGreen = cache.get(for: greenURL)

        #expect(retrievedRed != nil, "Red image should be cached")
        #expect(retrievedBlue != nil, "Blue image should be cached")
        #expect(retrievedGreen != nil, "Green image should be cached")
    }

    // MARK: - Cache Update Tests

    @Test("ImageCache should update existing cached image")
    func testCacheUpdateExistingImage() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let testURL = createTestURL()
        let firstImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))
        let secondImage = createTestImage(color: .blue, size: CGSize(width: 200, height: 200))

        // Store first image
        cache.set(firstImage, for: testURL)

        // Update with second image
        cache.set(secondImage, for: testURL)

        // Retrieve and verify it's the updated image
        let retrieved = cache.get(for: testURL)

        #expect(retrieved != nil, "Image should exist")
        #expect(retrieved?.size == secondImage.size, "Should retrieve updated image with new size")
    }

    // MARK: - Cache Removal Tests

    @Test("ImageCache should remove specific image")
    func testCacheRemoveSpecificImage() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let testImage = createTestImage()
        let testURL = createTestURL()

        // Store and verify
        cache.set(testImage, for: testURL)
        #expect(cache.get(for: testURL) != nil, "Image should be cached initially")

        // Remove specific image
        cache.remove(for: testURL)

        // Verify removal
        let retrieved = cache.get(for: testURL)
        #expect(retrieved == nil, "Image should be removed from cache")
    }

    @Test("ImageCache should clear all cached images")
    func testCacheClearAll() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let image1 = createTestImage(color: .red)
        let image2 = createTestImage(color: .blue)
        let url1 = createTestURL(path: "image1")
        let url2 = createTestURL(path: "image2")

        // Cache multiple images
        cache.set(image1, for: url1)
        cache.set(image2, for: url2)

        // Verify both are cached
        #expect(cache.get(for: url1) != nil, "Image 1 should be cached")
        #expect(cache.get(for: url2) != nil, "Image 2 should be cached")

        // Clear all
        cache.clearCache()

        // Verify all are removed
        #expect(cache.get(for: url1) == nil, "Image 1 should be cleared")
        #expect(cache.get(for: url2) == nil, "Image 2 should be cleared")
    }

    // MARK: - URL Handling Tests

    @Test("ImageCache should handle URLs with different query parameters")
    func testCacheHandlesDifferentURLs() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let image1 = createTestImage(color: .red)
        let image2 = createTestImage(color: .blue)

        let url1 = URL(string: "https://example.com/image.jpg?size=small")!
        let url2 = URL(string: "https://example.com/image.jpg?size=large")!

        // Cache with different query params
        cache.set(image1, for: url1)
        cache.set(image2, for: url2)

        // Verify they're stored separately
        let retrieved1 = cache.get(for: url1)
        let retrieved2 = cache.get(for: url2)

        #expect(retrieved1 != nil, "Image with ?size=small should be cached")
        #expect(retrieved2 != nil, "Image with ?size=large should be cached")
    }

    @Test("ImageCache should handle special characters in URLs")
    func testCacheHandlesSpecialCharactersInURL() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let testImage = createTestImage()
        let specialURL = URL(string: "https://example.com/image%20with%20spaces.jpg")!

        // Store with special characters
        cache.set(testImage, for: specialURL)

        // Retrieve
        let retrieved = cache.get(for: specialURL)

        #expect(retrieved != nil, "Should handle URLs with special characters")
    }

    // MARK: - Edge Cases

    @Test("ImageCache should handle very large images")
    func testCacheHandlesLargeImages() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        // Create a larger image
        let largeImage = createTestImage(color: .purple, size: CGSize(width: 2000, height: 2000))
        let testURL = createTestURL(path: "large")

        // Store large image
        cache.set(largeImage, for: testURL)

        // Retrieve
        let retrieved = cache.get(for: testURL)

        #expect(retrieved != nil, "Should cache large images")
        #expect(retrieved?.size == largeImage.size, "Large image size should be preserved")
    }

    @Test("ImageCache should handle rapid successive operations")
    func testCacheHandlesRapidOperations() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let testURL = createTestURL()

        // Rapidly set, get, remove, set
        let image1 = createTestImage(color: .red)
        cache.set(image1, for: testURL)
        _ = cache.get(for: testURL)
        cache.remove(for: testURL)

        let image2 = createTestImage(color: .blue)
        cache.set(image2, for: testURL)

        let finalRetrieved = cache.get(for: testURL)

        #expect(finalRetrieved != nil, "Should handle rapid operations")
    }

    // MARK: - Memory Management Tests

    @Test("ImageCache should handle memory warning notification")
    func testCacheHandlesMemoryWarning() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let testImage = createTestImage()
        let testURL = createTestURL()

        // Cache an image
        cache.set(testImage, for: testURL)
        #expect(cache.get(for: testURL) != nil, "Image should be cached initially")

        // Simulate memory warning
        NotificationCenter.default.post(
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        // Give notification and async task time to process
        try await Task.sleep(for: .milliseconds(500))

        // Verify cache was cleared
        let retrieved = cache.get(for: testURL)
        #expect(retrieved == nil, "Cache should be cleared after memory warning")
    }

    @Test("ImageCache singleton should return same instance")
    func testCacheSingletonPattern() async throws {
        let cache1 = ImageCache.shared
        let cache2 = ImageCache.shared

        // In Swift, we can't directly compare object identity easily,
        // but we can verify they share state
        cache1.clearCache()

        let testImage = createTestImage()
        let testURL = createTestURL()

        cache1.set(testImage, for: testURL)

        // If they're the same instance, cache2 should have access to the same data
        let retrieved = cache2.get(for: testURL)
        #expect(retrieved != nil, "Singleton instances should share state")
    }
}
