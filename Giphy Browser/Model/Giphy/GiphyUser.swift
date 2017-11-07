//
//  GiphyUser.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

struct GiphyUser: Codable {
    let username: String
    let displayName: String
    let twitterHandle: String
    let isVerified: Bool?
    
    private let bannerURLValue: String
    private let avatarURLValue: String
    private let profileURLValue: String
    
    var profileURL: URL? {
        return URL(string: profileURLValue)
    }
    
    var avatarURL: URL? {
        return URL(string: avatarURLValue)
    }
    
    var bannerURL: URL? {
        return URL(string: bannerURLValue)
    }
    
    enum CodingKeys: String, CodingKey {
        case avatarURLValue = "avatar_url"
        case bannerURLValue = "banner_url"
        case profileURLValue = "profile_url"
        case username
        case displayName = "display_name"
        case twitterHandle = "twitter"
        case isVerified = "is_verified"
    }
}

