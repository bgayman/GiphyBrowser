//
//  GiphyCollectionViewCell.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

class GiphyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var giphy: Giphy? {
        didSet {
            imageView.backgroundColor = nil
            let url = giphy?.images[GiphyViewModel.listImageType.rawValue]?.url
            imageView.sd_setImage(with: url)
        }
    }
}
