//
//  GiphyCollectionViewCell.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

/// Collection view cell that displays a GIF
class GiphyCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    var giphy: Giphy? {
        didSet {
            imageView.backgroundColor = nil
            let url = giphy?.images[GiphyViewModel.listImageType.rawValue]?.url
            imageView.sd_setImage(with: url)
        }
    }
}
