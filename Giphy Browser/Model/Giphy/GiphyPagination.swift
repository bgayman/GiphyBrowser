//
//  GiphyPagination.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Struct that represents the pagination data returned in a `GiphyResponse`
struct GiphyPagination: Codable {
    let totalCount: Int?
    let count: Int
    let offset: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case count
        case offset
    }
}
