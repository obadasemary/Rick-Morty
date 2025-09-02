//
//  FeedErrorTests.swift
//  UseCaseTests
//
//  Created by Abdelrahman Mohamed on 02.09.2025.
//

import Testing
import Foundation
@testable import UseCase

struct FeedErrorTests {
    
    @Test("FeedError network case equality")
    func test_feedError_network_shouldBeEqual() {
        // Given
        let error1 = FeedError.network
        let error2 = FeedError.network
        
        // Then
        #expect(error1 == error2)
    }
    
    @Test("FeedError server case with same status equality")
    func test_feedError_server_withSameStatus_shouldBeEqual() {
        // Given
        let error1 = FeedError.server(status: 500)
        let error2 = FeedError.server(status: 500)
        
        // Then
        #expect(error1 == error2)
    }
    
    @Test("FeedError server case with different status inequality")
    func test_feedError_server_withDifferentStatus_shouldNotBeEqual() {
        // Given
        let error1 = FeedError.server(status: 500)
        let error2 = FeedError.server(status: 404)
        
        // Then
        #expect(error1 != error2)
    }
    
    @Test("FeedError server case with nil status equality")
    func test_feedError_server_withNilStatus_shouldBeEqual() {
        // Given
        let error1 = FeedError.server(status: nil)
        let error2 = FeedError.server(status: nil)
        
        // Then
        #expect(error1 == error2)
    }
    
    @Test("FeedError server case nil vs non-nil status inequality")
    func test_feedError_server_nilVsNonNilStatus_shouldNotBeEqual() {
        // Given
        let error1 = FeedError.server(status: nil)
        let error2 = FeedError.server(status: 500)
        
        // Then
        #expect(error1 != error2)
    }
    
    @Test("FeedError decoding case equality")
    func test_feedError_decoding_shouldBeEqual() {
        // Given
        let error1 = FeedError.decoding
        let error2 = FeedError.decoding
        
        // Then
        #expect(error1 == error2)
    }
    
    @Test("FeedError invalidResponse case equality")
    func test_feedError_invalidResponse_shouldBeEqual() {
        // Given
        let error1 = FeedError.invalidResponse
        let error2 = FeedError.invalidResponse
        
        // Then
        #expect(error1 == error2)
    }
    
    @Test("FeedError unknown case with same message equality")
    func test_feedError_unknown_withSameMessage_shouldBeEqual() {
        // Given
        let message = "Custom error message"
        let error1 = FeedError.unknown(message: message)
        let error2 = FeedError.unknown(message: message)
        
        // Then
        #expect(error1 == error2)
    }
    
    @Test("FeedError unknown case with different message inequality")
    func test_feedError_unknown_withDifferentMessage_shouldNotBeEqual() {
        // Given
        let error1 = FeedError.unknown(message: "Error 1")
        let error2 = FeedError.unknown(message: "Error 2")
        
        // Then
        #expect(error1 != error2)
    }
    
    @Test("FeedError different cases inequality")
    func test_feedError_differentCases_shouldNotBeEqual() {
        // Given
        let networkError = FeedError.network
        let serverError = FeedError.server(status: 500)
        let decodingError = FeedError.decoding
        let invalidResponseError = FeedError.invalidResponse
        let unknownError = FeedError.unknown(message: "Unknown")
        
        // Then
        #expect(networkError != serverError)
        #expect(networkError != decodingError)
        #expect(networkError != invalidResponseError)
        #expect(networkError != unknownError)
        
        #expect(serverError != decodingError)
        #expect(serverError != invalidResponseError)
        #expect(serverError != unknownError)
        
        #expect(decodingError != invalidResponseError)
        #expect(decodingError != unknownError)
        
        #expect(invalidResponseError != unknownError)
    }
    
    @Test("FeedError can be used in Result type")
    func test_feedError_inResultType_shouldWorkCorrectly() {
        // Given
        let successResult: Result<String, FeedError> = .success("Success")
        let networkFailureResult: Result<String, FeedError> = .failure(.network)
        let serverFailureResult: Result<String, FeedError> = .failure(.server(status: 404))
        
        // Then
        switch successResult {
        case .success(let value):
            #expect(value == "Success")
        case .failure:
            #expect(Bool(false), "Should not be failure")
        }
        
        switch networkFailureResult {
        case .success:
            #expect(Bool(false), "Should not be success")
        case .failure(let error):
            #expect(error == .network)
        }
        
        switch serverFailureResult {
        case .success:
            #expect(Bool(false), "Should not be success")
        case .failure(let error):
            #expect(error == .server(status: 404))
        }
    }
    
    @Test("FeedError can be thrown and caught")
    func test_feedError_throwAndCatch_shouldWorkCorrectly() async {
        // Given
        func throwingFunction() throws {
            throw FeedError.network
        }
        
        // When & Then
        await #expect(throws: FeedError.network) {
            try throwingFunction()
        }
    }
    
    @Test("FeedError associated values accessibility")
    func test_feedError_associatedValues_shouldBeAccessible() {
        // Given
        let serverError = FeedError.server(status: 500)
        let unknownError = FeedError.unknown(message: "Test message")
        
        // When & Then
        switch serverError {
        case .server(let status):
            #expect(status == 500)
        default:
            #expect(Bool(false), "Should match server case")
        }
        
        switch unknownError {
        case .unknown(let message):
            #expect(message == "Test message")
        default:
            #expect(Bool(false), "Should match unknown case")
        }
    }
}

