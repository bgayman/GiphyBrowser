//
//  GiphyResponse.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Struct that represents the full response from the Giphy API
struct GiphyResponse: Codable {
    let giphies: [Giphy]
    let pagination: GiphyPagination
    let metadata: GiphyMetadata
    
    enum CodingKeys: String, CodingKey {
        case giphies = "data"
        case pagination
        case metadata = "meta"
    }
}
