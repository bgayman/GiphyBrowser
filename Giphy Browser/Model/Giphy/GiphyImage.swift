//
//  GiphyImage.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Struct that represents a `Giphy` in a specific incarnation
struct GiphyImage: Codable {
    
    // MARK: - Pivate Properties
    private let widthValue: String?
    private let heightValue: String?
    private let framesValue: String?
    private let sizeValue: String?
    private let mp4SizeValue: String?
    private let webpSizeValue: String?
    private let webpURLValue: String?
    private let urlValue: String?
    private let mp4URLValue: String?
    
    // MARK: - Computed Properties
    var width: Int {
        return Int(widthValue ?? "") ?? 0
    }
    
    var height: Int {
        return Int(heightValue ?? "") ?? 0
    }
    
    var size: Int {
        return Int(sizeValue ?? "" ) ?? 0
    }
    
    var frames: Int {
        return Int(framesValue ?? "") ?? 0
    }
    
    var mp4Size: Int {
        return Int(mp4SizeValue ?? "") ?? 0
    }
    
    var webpSize: Int {
        return Int(webpSizeValue ?? "") ?? 0
    }
    
    var webpURL: URL? {
        return URL(string: webpURLValue ?? "")
    }
    
    var url: URL? {
        return URL(string: urlValue ?? "")
    }
    
    var mp4URL: URL? {
        return URL(string: mp4URLValue ?? "")
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case urlValue = "url"
        case widthValue = "width"
        case heightValue = "height"
        case sizeValue = "size"
        case framesValue = "frames"
        case mp4URLValue = "mp4"
        case mp4SizeValue = "mp4_size"
        case webpURLValue = "webp"
        case webpSizeValue = "webp_size"
    }
}
