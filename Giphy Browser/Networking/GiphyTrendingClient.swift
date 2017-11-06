//
//  GiphyTrendingClient.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Client interface to Giphy Trending API
struct GiphyTrendingClient {
    static func getTrending(_ limit: Int = 25, offset: Int = 0, completion: @escaping GiphyResponseCompletion){
        guard let url = GiphyURLConstructor.makeTrendingURL(with: limit, offset: offset) else {
            completion(.error(error: WebserviceError.invalidURL))
            return
        }
        Webservice.dataTask(with: url, completion: completion)
    }
}
