//
//  NetworkError.swift
//  RickMortyNetworkLayer
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation

public enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(statusCode: Int)
}
