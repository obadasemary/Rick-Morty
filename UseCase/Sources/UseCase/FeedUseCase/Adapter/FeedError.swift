//
//  FeedError.swift
//  UseCase
//
//  Created by Abdelrahman Mohamed on 02.09.2025.
//

import Foundation

public enum FeedError: Error, Equatable {
    case network
    case server(status: Int?)
    case decoding
    case invalidResponse
    case unknown(message: String)
}
