//
//  GiphySearchClient+TestData.swift
//  Giphy BrowserTests
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

extension GiphySearchClient {
    static func loadTestData() -> GiphyResponse? {
        let bundle = Bundle(for: Giphy_BrowserTests.self)
        guard let url = bundle.url(forResource: "GiphyTestData", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        var response: GiphyResponse? = nil
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Giphy.dateFormatter)
            response = try decoder.decode(GiphyResponse.self, from: data)
        }
        catch {
            print(error)
        }
        return response
    }
}
