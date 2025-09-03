//
//  MockNetworkService.swift
//  RickMortyRepository
//
//  Created by Abdelrahman Mohamed on 03.09.2025.
//

import Foundation
import RickMortyNetworkLayer
@testable import RickMortyRepository

final class MockNetworkService: NetworkService, @unchecked Sendable {
    
    private var responses: [Any] = []
    private var errors: [Error] = []
    private var callCount = 0
    
    func setResponse<T>(_ response: T) {
        responses.append(response)
    }
    
    func setError(_ error: Error) {
        errors.append(error)
    }
    
    func request<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type
    ) async throws -> T {
        callCount += 1
        
        if !errors.isEmpty {
            let error = errors.removeFirst()
            throw error
        }
        
        guard !responses.isEmpty else {
            throw NetworkError.invalidResponse
        }
        
        let response = responses.removeFirst()
        guard let typedResponse = response as? T else {
            throw NetworkError.invalidResponse
        }
        
        return typedResponse
    }
    
    func getCallCount() -> Int {
        return callCount
    }
    
    func reset() {
        responses.removeAll()
        errors.removeAll()
        callCount = 0
    }
}
