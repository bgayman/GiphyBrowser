//
//  Giphy.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Data struct of the Gif entity in the Giphy API
struct Giphy: Codable {
    
    // MARK: - Static Properties
    static let dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    // MARK: - Public Properties
    let type: String
    let id: String
    let slug: String
    let url: URL
    let embedURL: URL
    let username: String?
    let rating: String
    let sourceTopLevelDomain: String
    let importDate: Date
    let trendingDate: String?
    let images: [String: GiphyImage]
    let title: String
    let user: GiphyUser?
    
    // MARK: - Private Properties
    private let bitlyGifURLValue: String
    private let bitlyURLValue: String
    private let sourceValue: String
    private let contentURLValue: String
    private let sourcePostURLValue: String
    private let isIndexableValue: Int?
    
    // MARK: - Computed Properties
    var contentURL: URL? {
        return URL(string: contentURLValue)
    }
    
    var isIndexable: Bool {
        return isIndexableValue != 0
    }
    
    var bitlyURL: URL? {
        return URL(string: bitlyURLValue)
    }
    
    var bitlyGifURL: URL? {
        return URL(string: bitlyGifURLValue)
    }
    
    var source: URL? {
        return URL(string: sourceValue)
    }
    
    var sourcePostURL: URL? {
        return URL(string: sourcePostURLValue)
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case type
        case id
        case slug
        case url
        case bitlyGifURLValue = "bitly_gif_url"
        case bitlyURLValue = "bitly_url"
        case embedURL = "embed_url"
        case username
        case sourceValue = "source"
        case rating
        case contentURLValue = "content_url"
        case sourceTopLevelDomain = "source_tld"
        case sourcePostURLValue = "source_post_url"
        case isIndexableValue = "is_indexable"
        case importDate = "import_datetime"
        case trendingDate = "trending_datetime"
        case images
        case title
        case user
    }
}

extension Giphy: Equatable {
    static func == (lhs: Giphy, rhs: Giphy) -> Bool {
        return lhs.type == rhs.type &&
               lhs.id == rhs.id &&
               lhs.slug == rhs.slug &&
               lhs.url == rhs.url &&
               lhs.embedURL == rhs.embedURL &&
               lhs.username == rhs.username &&
               lhs.rating == rhs.rating &&
               lhs.sourceTopLevelDomain == rhs.sourceTopLevelDomain &&
               lhs.importDate == rhs.importDate &&
               lhs.trendingDate == rhs.trendingDate &&
               lhs.title == rhs.title
    }
}
