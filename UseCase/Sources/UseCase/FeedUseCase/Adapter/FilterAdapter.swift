//
//  FilterAdapter.swift
//  UseCase
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import Foundation

public enum FilterAdapter: CaseIterable, Equatable {
    case alive
    case dead
    case unknown
}

public extension FilterAdapter {
    var toCharacterStatus: Status {
        switch self {
        case .alive: return .alive
        case .dead: return .dead
        case .unknown: return .unknown
        }
    }
}
