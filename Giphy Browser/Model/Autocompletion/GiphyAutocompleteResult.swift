//
//  GiphyAutocompleteResult.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Struct that contains the an array autocompletion possibilities
struct GiphyAutocompleteResult: Codable {
    let results: [GiphyAutocomplete]
    
    enum CodingKeys: String, CodingKey {
        case results = "objects"
    }
}
