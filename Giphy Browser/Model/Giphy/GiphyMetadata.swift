//
//  GiphyMetadata.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Struct that represents the metadata associated with a `GiphyResponse`
struct GiphyMetadata: Codable {
    let status: Int
    let message: String
    let responseID: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case message = "msg"
        case responseID = "response_id"
    }
}
