//
//  GiphyAutocompleteResponse.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Struct that represents a full autocompletion response
struct GiphyAutocompleteResponse: Codable {
    let status: Int
    let result: GiphyAutocompleteResult
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case result = "result"
    }
}
