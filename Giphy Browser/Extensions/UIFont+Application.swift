//
//  UIFont+Application.swift
//  Giphy Browser
//
//  Created by B Gay on 11/6/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func appFont(textStyle: UIFontTextStyle, weight: UIFont.Weight) -> UIFont {
        let preferredFont = UIFont.preferredFont(forTextStyle: textStyle)
        return appFont(weight: weight, pointSize: preferredFont.pointSize)
    }
    
    static func appFont(weight: UIFont.Weight, pointSize: CGFloat) -> UIFont {
        
        switch weight {
        case UIFont.Weight.heavy:
            return UIFont(name: "AvenirNext-Heavy", size: pointSize)!
        case UIFont.Weight.black:
            return UIFont(name: "AvenirNext-Heavy", size: pointSize)!
        case UIFont.Weight.bold:
            return UIFont(name: "AvenirNext-Bold", size: pointSize)!
        case UIFont.Weight.semibold:
            return UIFont(name: "AvenirNext-DemiBold", size: pointSize)!
        case UIFont.Weight.medium:
            return UIFont(name: "AvenirNext-Medium", size: pointSize)!
        case UIFont.Weight.regular:
            return UIFont(name: "AvenirNext-Regular", size: pointSize)!
        case UIFont.Weight.light:
            return UIFont(name: "AvenirNext-Regular", size: pointSize)!
        case UIFont.Weight.thin:
            return UIFont(name: "AvenirNext-UltraLight", size: pointSize)!
        case UIFont.Weight.ultraLight:
            return UIFont(name: "AvenirNext-UltraLight", size: pointSize)!
        default:
            return UIFont(name: "AvenirNext-Regular", size: pointSize)!
        }
    }
}
