//
//  GiphyURLConstructor.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Structure that conventiently constructs Giphy URLs
struct GiphyURLConstructor {
    
    struct Constants {
        static let apiSecretKey = <# Replace with API Key #> //  available at https://developers.giphy.com
        static let scheme = "https"
        static let host = "api.giphy.com"
        static let trendingPath = "/v1/gifs/trending"
        static let searchPath = "/v1/gifs/search"
        static let autocompletionHost = "giphy.com"
        static let autocompletionPath = "/ajax/tags/search/"
    }
    
    enum RequestKeys: String {
        case api = "api_key"
        case query = "q"
        case limit
        case offset
        case language = "lang"
        case format = "fmt"
    }
    
    static func makeSearchURL(with searchString: String, limit: Int, offset: Int, format: String = "json") -> URL? {
        guard let urlSearchString = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return nil }
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.searchPath
        
        let searchQueryItem = URLQueryItem(name: RequestKeys.query.rawValue, value: urlSearchString)
        let limitItem = URLQueryItem(name: RequestKeys.limit.rawValue, value: String(limit))
        let offsetItem = URLQueryItem(name: RequestKeys.offset.rawValue, value: String(offset))
        let formatItem = URLQueryItem(name: RequestKeys.format.rawValue, value: String(format))
        let apiKeyItem = URLQueryItem(name: RequestKeys.api.rawValue, value: Constants.apiSecretKey)
        
        urlComponents.queryItems = [searchQueryItem, apiKeyItem, limitItem, offsetItem, formatItem]
        return urlComponents.url
    }
    
    static func makeTrendingURL(with limit: Int, offset: Int, format: String = "json") -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.trendingPath
        
        let limitItem = URLQueryItem(name: RequestKeys.limit.rawValue, value: String(limit))
        let offsetItem = URLQueryItem(name: RequestKeys.offset.rawValue, value: String(offset))
        let formatItem = URLQueryItem(name: RequestKeys.format.rawValue, value: String(format))
        let apiKeyItem = URLQueryItem(name: RequestKeys.api.rawValue, value: Constants.apiSecretKey)
        
        urlComponents.queryItems = [apiKeyItem, limitItem, offsetItem, formatItem]
        return urlComponents.url
    }
    
    static func makeAutocompletionURL(with search: String) -> URL? {
        guard let urlSearchString = search.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return nil }
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.autocompletionHost
        urlComponents.path = Constants.autocompletionPath
        
        let searchQueryItem = URLQueryItem(name: RequestKeys.query.rawValue, value: urlSearchString)
        urlComponents.queryItems = [searchQueryItem]
        return urlComponents.url
    }
    
}
