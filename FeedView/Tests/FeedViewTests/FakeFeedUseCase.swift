//
//  FakeFeedUseCase.swift
//  FeedView
//
//  Created by Abdelrahman Mohamed on 02.09.2025.
//

import Foundation
import UseCase

final class FakeFeedUseCase: FeedUseCaseProtocol {
    enum FakeError: Error { case notScheduled }
    
    var scheduled: [String: ScheduledPage] = [:]
    private(set) var calls: [(page: Int, status: String?)] = []
    
    func execute(page: Int?, status: String?) async throws -> CharactersPageResponse {
        let pageValue = page ?? 1
        calls.append((pageValue, status))
        let key = Self.key(page: pageValue, status: status)
        guard let plan = scheduled[key] else { throw FakeError.notScheduled }
        switch plan.result {
        case .success(let response): return response
        case .failure(let error): throw error
        }
    }
    
    static func key(page: Int, status: String?) -> String { "\(page)|\(status ?? "nil")" }
}
