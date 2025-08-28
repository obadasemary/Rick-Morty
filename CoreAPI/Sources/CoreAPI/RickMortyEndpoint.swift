//
//  RickMortyEndpoint.swift
//  CoreAPI
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation
import RickMortyNetworkLayer

public enum RickMortyEndpoint {
    /// GET https://rickandmortyapi.com/api/character
    /// Optional query params:
    ///  - page: Int (1-based)
    ///  - status: String (e.g. "alive", "dead", "unknown")
    case getCharacters(page: Int?, status: String?)
}

extension RickMortyEndpoint: Endpoint {
 
    public var baseURL: String {
        "https://rickandmortyapi.com/api"
    }
    
    // Path for each case
    public var path: String {
        switch self {
        case .getCharacters:
            "/character"
        }
    }
    
    // HTTP method for each case
    public var method: HTTPMethod {
        switch self {
        case .getCharacters:
            .get
        }
    }
    
    // Query parameters for GET requests
    public var parameters: [String: Any]? {
        switch self {
        case let .getCharacters(page, status):
            var params: [String: Any] = [:]
            if let page {
                params["page"] = page
            }
            if let status, !status.isEmpty {
                params["status"] = status
            }
            return params.isEmpty ? nil : params
        }
    }
    
    // Content type for requests
    public var contentType: String {
        "application/json"
    }
}
