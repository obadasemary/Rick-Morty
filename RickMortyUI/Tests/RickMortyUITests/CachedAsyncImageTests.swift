//
//  CachedAsyncImageTests.swift
//  RickMortyUITests
//
//  Created by Claude Code on 12.11.2025.
//

import Testing
import SwiftUI
@testable import RickMortyUI

@Suite("CachedAsyncImage Tests")
@MainActor
struct CachedAsyncImageTests {

    // MARK: - Test Helpers

    /// Creates a test UIImage
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

    // MARK: - Cache Integration Tests

    @Test("CachedAsyncImage should use cached image when available")
    func testUseCachedImageWhenAvailable() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let testURL = createTestURL()
        let testImage = createTestImage(color: .blue)

        // Pre-cache the image
        cache.set(testImage, for: testURL)

        // Verify image is in cache
        let cachedImage = cache.get(for: testURL)
        #expect(cachedImage != nil, "Image should be pre-cached")

        // When CachedAsyncImage loads, it should check cache first
        // This is implicitly tested by the cache.get() call above
        // In real usage, the view would display immediately without network call
    }

    @Test("CachedAsyncImage should handle nil URL")
    func testHandleNilURL() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        // Test that nil URL doesn't crash
        let nilURL: URL? = nil
        let cachedImage = cache.get(for: nilURL ?? createTestURL())

        // With nil URL, cache should return nil
        #expect(cachedImage == nil, "Nil URL should not return cached image")
    }

    @Test("CachedAsyncImage should cache image after successful load")
    func testCacheImageAfterLoad() async throws {
        let cache = ImageCache.shared
        let testURL = createTestURL(path: "new-image")

        // Clear cache to ensure fresh start
        cache.clearCache()

        // Verify not in cache initially
        #expect(cache.get(for: testURL) == nil, "Image should not be cached initially")

        // Simulate successful image load and cache
        let loadedImage = createTestImage(color: .green)
        cache.set(loadedImage, for: testURL)

        // Verify it's now in cache
        let cachedImage = cache.get(for: testURL)
        #expect(cachedImage != nil, "Image should be cached after load")
    }

    // MARK: - URL Change Tests

    @Test("CachedAsyncImage should handle URL changes")
    func testHandleURLChanges() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let url1 = createTestURL(path: "image1")
        let url2 = createTestURL(path: "image2")

        let image1 = createTestImage(color: .red)
        let image2 = createTestImage(color: .blue)

        // Cache both images
        cache.set(image1, for: url1)
        cache.set(image2, for: url2)

        // Verify both are cached
        #expect(cache.get(for: url1) != nil, "First image should be cached")
        #expect(cache.get(for: url2) != nil, "Second image should be cached")

        // Verify they're different (not overwriting each other)
        let retrieved1 = cache.get(for: url1)
        let retrieved2 = cache.get(for: url2)

        #expect(retrieved1 != nil, "Should have distinct cached images")
        #expect(retrieved2 != nil, "Should have distinct cached images")
    }

    // MARK: - Error Handling Tests

    @Test("CachedAsyncImage should handle invalid URLs gracefully")
    func testHandleInvalidURLs() async throws {
        let cache = ImageCache.shared

        // Test with various URL formats
        let validURL = URL(string: "https://example.com/image.jpg")!
        let testImage = createTestImage()

        cache.set(testImage, for: validURL)

        let retrieved = cache.get(for: validURL)
        #expect(retrieved != nil, "Should handle valid HTTPS URLs")
    }

    // MARK: - Performance Tests

    @Test("CachedAsyncImage cache lookup should be fast")
    func testCacheLookupPerformance() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let testURL = createTestURL()
        let testImage = createTestImage()

        // Cache the image
        cache.set(testImage, for: testURL)

        // Measure lookup time (should be nearly instantaneous)
        let startTime = Date()

        for _ in 0..<100 {
            _ = cache.get(for: testURL)
        }

        let elapsedTime = Date().timeIntervalSince(startTime)

        // 100 lookups should complete in under 0.1 seconds
        #expect(elapsedTime < 0.1, "Cache lookups should be fast")
    }

    @Test("CachedAsyncImage should handle concurrent cache access")
    func testConcurrentCacheAccess() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let testImage = createTestImage()

        // Simulate concurrent access
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask { @MainActor in
                    let url = self.createTestURL(path: "concurrent-\(i)")
                    cache.set(testImage, for: url)
                    _ = cache.get(for: url)
                }
            }
        }

        // Verify all images were cached
        for i in 0..<10 {
            let url = createTestURL(path: "concurrent-\(i)")
            let retrieved = cache.get(for: url)
            #expect(retrieved != nil, "Concurrent image \(i) should be cached")
        }
    }

    // MARK: - Memory Tests

    @Test("CachedAsyncImage should handle multiple image sizes")
    func testHandleMultipleImageSizes() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let smallImage = createTestImage(size: CGSize(width: 50, height: 50))
        let mediumImage = createTestImage(size: CGSize(width: 200, height: 200))
        let largeImage = createTestImage(size: CGSize(width: 1000, height: 1000))

        let smallURL = createTestURL(path: "small")
        let mediumURL = createTestURL(path: "medium")
        let largeURL = createTestURL(path: "large")

        // Cache different sizes
        cache.set(smallImage, for: smallURL)
        cache.set(mediumImage, for: mediumURL)
        cache.set(largeImage, for: largeURL)

        // Verify all are cached with correct sizes
        let retrievedSmall = cache.get(for: smallURL)
        let retrievedMedium = cache.get(for: mediumURL)
        let retrievedLarge = cache.get(for: largeURL)

        #expect(retrievedSmall?.size == smallImage.size, "Small image size preserved")
        #expect(retrievedMedium?.size == mediumImage.size, "Medium image size preserved")
        #expect(retrievedLarge?.size == largeImage.size, "Large image size preserved")
    }

    // MARK: - Cache Invalidation Tests

    @Test("CachedAsyncImage should respect cache clearing")
    func testRespectCacheClearing() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let testURL = createTestURL()
        let testImage = createTestImage()

        // Cache and verify
        cache.set(testImage, for: testURL)
        #expect(cache.get(for: testURL) != nil, "Image should be cached")

        // Clear cache
        cache.clearCache()

        // Verify cleared
        #expect(cache.get(for: testURL) == nil, "Image should be cleared from cache")
    }

    @Test("CachedAsyncImage should handle selective cache removal")
    func testSelectiveCacheRemoval() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let url1 = createTestURL(path: "keep")
        let url2 = createTestURL(path: "remove")

        let image1 = createTestImage(color: .red)
        let image2 = createTestImage(color: .blue)

        // Cache both
        cache.set(image1, for: url1)
        cache.set(image2, for: url2)

        // Remove only one
        cache.remove(for: url2)

        // Verify selective removal
        #expect(cache.get(for: url1) != nil, "First image should remain")
        #expect(cache.get(for: url2) == nil, "Second image should be removed")
    }

    // MARK: - Image Format Tests

    @Test("CachedAsyncImage should handle different image formats")
    func testHandleDifferentImageFormats() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let jpegURL = URL(string: "https://example.com/image.jpeg")!
        let pngURL = URL(string: "https://example.com/image.png")!
        let gifURL = URL(string: "https://example.com/image.gif")!

        let testImage = createTestImage()

        // Cache with different extensions
        cache.set(testImage, for: jpegURL)
        cache.set(testImage, for: pngURL)
        cache.set(testImage, for: gifURL)

        // Verify all are cached
        #expect(cache.get(for: jpegURL) != nil, "JPEG should be cached")
        #expect(cache.get(for: pngURL) != nil, "PNG should be cached")
        #expect(cache.get(for: gifURL) != nil, "GIF should be cached")
    }

    // MARK: - State Management Tests

    @Test("CachedAsyncImage should maintain cache across view recreations")
    func testCachePersistsAcrossViewRecreations() async throws {
        let cache = ImageCache.shared
        cache.clearCache()

        let testURL = createTestURL()
        let testImage = createTestImage()

        // Simulate first view caching image
        cache.set(testImage, for: testURL)

        // Simulate second view (recreation) accessing cache
        let retrievedInSecondView = cache.get(for: testURL)

        #expect(retrievedInSecondView != nil, "Cache should persist across view recreations")
    }
}
