//
//  FilterAdapterTests.swift
//  UseCaseTests
//
//  Created by Abdelrahman Mohamed on 02.09.2025.
//

import Testing
import Foundation
@testable import UseCase

struct FilterAdapterTests {
    
    @Test("FilterAdapter has all expected cases")
    func test_filterAdapter_allCases_shouldContainExpectedValues() {
        // Given
        let allCases = FilterAdapter.allCases
        
        // Then
        #expect(allCases.count == 3)
        #expect(allCases.contains(.alive))
        #expect(allCases.contains(.dead))
        #expect(allCases.contains(.unknown))
    }
    
    @Test("FilterAdapter alive case maps to Status.alive")
    func test_filterAdapter_alive_shouldMapToStatusAlive() {
        // Given
        let filter = FilterAdapter.alive
        
        // When
        let status = filter.toCharacterStatus
        
        // Then
        #expect(status == Status.alive)
    }
    
    @Test("FilterAdapter dead case maps to Status.dead")
    func test_filterAdapter_dead_shouldMapToStatusDead() {
        // Given
        let filter = FilterAdapter.dead
        
        // When
        let status = filter.toCharacterStatus
        
        // Then
        #expect(status == Status.dead)
    }
    
    @Test("FilterAdapter unknown case maps to Status.unknown")
    func test_filterAdapter_unknown_shouldMapToStatusUnknown() {
        // Given
        let filter = FilterAdapter.unknown
        
        // When
        let status = filter.toCharacterStatus
        
        // Then
        #expect(status == Status.unknown)
    }
    
    @Test("FilterAdapter all cases map to corresponding Status cases")
    func test_filterAdapter_allCases_shouldMapToCorrespondingStatus() {
        // Given & When & Then
        for filterCase in FilterAdapter.allCases {
            let expectedStatus: Status
            
            switch filterCase {
            case .alive:
                expectedStatus = .alive
            case .dead:
                expectedStatus = .dead
            case .unknown:
                expectedStatus = .unknown
            }
            
            #expect(filterCase.toCharacterStatus == expectedStatus)
        }
    }
    
    @Test("FilterAdapter equality works correctly")
    func test_filterAdapter_equality_shouldWorkCorrectly() {
        // Given
        let alive1 = FilterAdapter.alive
        let alive2 = FilterAdapter.alive
        let dead = FilterAdapter.dead
        
        // Then
        #expect(alive1 == alive2)
        #expect(alive1 != dead)
    }
    
    @Test("FilterAdapter can be used in Set operations")
    func test_filterAdapter_inSet_shouldWorkCorrectly() {
        // Given
        let filters: Set<FilterAdapter> = [.alive, .dead, .unknown, .alive] // Duplicate alive
        
        // Then
        #expect(filters.count == 3) // Should contain unique values only
        #expect(filters.contains(.alive))
        #expect(filters.contains(.dead))
        #expect(filters.contains(.unknown))
    }
    
    @Test("FilterAdapter can be used in switch statements")
    func test_filterAdapter_inSwitch_shouldWorkCorrectly() {
        // Given
        let filters = FilterAdapter.allCases
        
        // When & Then
        for filter in filters {
            let description: String
            
            switch filter {
            case .alive:
                description = "alive"
            case .dead:
                description = "dead"
            case .unknown:
                description = "unknown"
            }
            
            #expect(!description.isEmpty)
        }
    }
    
    @Test("FilterAdapter CaseIterable provides correct iteration")
    func test_filterAdapter_caseIterable_shouldProvideCorrectIteration() {
        // Given
        var iteratedCases: [FilterAdapter] = []
        
        // When
        for filterCase in FilterAdapter.allCases {
            iteratedCases.append(filterCase)
        }
        
        // Then
        #expect(iteratedCases.count == 3)
        #expect(iteratedCases.contains(.alive))
        #expect(iteratedCases.contains(.dead))
        #expect(iteratedCases.contains(.unknown))
    }
}

