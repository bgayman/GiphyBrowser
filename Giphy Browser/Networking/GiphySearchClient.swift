//
//  GiphySearchClient.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

typealias GiphyResponseCompletion = (Result<GiphyResponse>) -> Void

/// Client interface to Giphy Search API
struct GiphySearchClient {
    static func getSearchResult(for searchString: String, limit: Int = 25, offset: Int = 0, completion: @escaping GiphyResponseCompletion) {
        guard let url = GiphyURLConstructor.makeSearchURL(with: searchString, limit: limit, offset: offset) else {
            completion(.error(error: WebserviceError.invalidURL))
            return
        }
        Webservice.dataTask(with: url, completion: completion)
    }
}
