//
//  GiphyAutocompletionClient.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

typealias GiphyAutocompleteResponseCompletion = (Result<GiphyAutocompleteResponse>) -> Void

struct GiphyAutocompleteClient {
    static func getAutocompletions(for searchString: String, completion: @escaping  GiphyAutocompleteResponseCompletion) {
        guard let url = GiphyURLConstructor.makeAutocompletionURL(with: searchString) else {
            completion(.error(error: WebserviceError.invalidURL))
            return
        }
        Webservice.dataTask(with: url, completion: completion)
    }
}
