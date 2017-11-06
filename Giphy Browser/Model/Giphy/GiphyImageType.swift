//
//  GiphyImageType.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Keys for the `images` property of a `Giphy`
enum GiphyImageType: String, Codable {
    case fixedHeight = "fixed_height"
    case fixedHeightStill = "fixed_height_still"
    case fixedHeightDownsampled = "fixed_height_downsampled"
    case fixedWidth = "fixed_width"
    case fixedWidthStill = "fixed_width_still"
    case fixedWidthDownsampled = "fixed_width_downsampled"
    case fixedHeightSmall = "fixed_height_small"
    case fixedHeightSmallStill = "fixed_height_small_still"
    case fixedWidthSmall = "fixed_width_small"
    case fixedWidthSmallStill = "fixed_width_small_still"
    case downsized
    case downsizedStill = "downsized_still"
    case downsizedLarge = "downsized_large"
    case downsizedMedium = "downsized_medium"
    case downsizedSmall = "downsized_small"
    case original
    case originalStill = "original_still"
    case originalMP4 = "original_mp4"
    case looping
    case preview
    case previewGif = "preview_gif"
    case previewWebP = "preview_webp"
    case still480Width = "480w_still"
}
