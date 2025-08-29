//
//  Filter.swift
//  FeedView
//
//  Created by Abdelrahman Mohamed on 29.08.2025.
//

import Foundation
import UseCase

enum Filter: CaseIterable, Equatable {
    case alive
    case dead
    case unknown
}

extension Filter {
    var toCharacterStatus: Status {
        switch self {
        case .alive: return .alive
        case .dead: return .dead
        case .unknown: return .unknown
        }
    }
}
