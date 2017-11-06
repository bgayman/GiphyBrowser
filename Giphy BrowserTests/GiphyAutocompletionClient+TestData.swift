//
//  GiphyAutocompletionClient+TestData.swift
//  Giphy BrowserTests
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

extension GiphyAutocompleteClient {
    static func loadTestData() -> GiphyAutocompleteResponse? {
        let bundle = Bundle(for: Giphy_BrowserTests.self)
        guard let url = bundle.url(forResource: "GiphyAutocompleteTestData", withExtension: "json"),
            let data = try? Data(contentsOf: url) else { return nil }
        var response: GiphyAutocompleteResponse? = nil
        do {
            let decoder = JSONDecoder()
            response = try decoder.decode(GiphyAutocompleteResponse.self, from: data)
        }
        catch {
            print(error)
        }
        return response
    }
}
