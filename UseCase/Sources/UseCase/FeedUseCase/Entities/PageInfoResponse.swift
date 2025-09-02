//
//  PageInfoResponse.swift
//  UseCase
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation

// MARK: - Pagination info
public struct PageInfoResponse: Decodable, Sendable {
    public let count: Int
    public let pages: Int
    public let next: URL?
    public let prev: URL?

    private enum CodingKeys: String, CodingKey {
        case count, pages, next, prev
    }
    
    public init(count: Int, pages: Int, next: URL?, prev: URL?) {
        self.count = count
        self.pages = pages
        self.next = next
        self.prev = prev
    }
}
