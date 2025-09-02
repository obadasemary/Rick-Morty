//
//  ScheduledPage.swift
//  FeedViewTests
//
//  Created by Abdelrahman Mohamed on 02.09.2025.
//

import UseCase
import Foundation

struct ScheduledPage {
    let page: Int
    let status: String?
    let result: Result<CharactersPageResponse, Error>
}
