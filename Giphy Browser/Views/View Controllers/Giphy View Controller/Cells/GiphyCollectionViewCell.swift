//
//  GiphyCollectionViewCell.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import SDWebImage
import FLAnimatedImage

/// Collection view cell that displays a GIF
class GiphyCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: FLAnimatedImageView!
    
    // MARK: - Properties
    var giphy: Giphy? {
        didSet {
            let url = giphy?.images[GiphyViewModel.listImageType.rawValue]?.url
            imageView.sd_setImage(with: url)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.backgroundColor = nil
    }
}
