//
//  GiphyAutocomplete.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Struct that represents the a single autocompletion possibility
struct GiphyAutocomplete: Codable {
    let name: String
    let nameEncoded: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case nameEncoded = "name_encoded"
    }
}

extension GiphyAutocomplete: Equatable {
    static func == (lhs: GiphyAutocomplete, rhs: GiphyAutocomplete) -> Bool {
        return lhs.name == rhs.name && lhs.nameEncoded == rhs.nameEncoded
    }
}

extension GiphyAutocomplete: Hashable {
    
    var hashValue: Int {
        return name.hashValue ^ nameEncoded.hashValue
    }
}
