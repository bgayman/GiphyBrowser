//
//  StoryboardInitializable.swift
//  2xWWDC
//
//  Created by B Gay on 11/6/17.
//  Copyright © 2017 B Gay. All rights reserved.
//

import UIKit

/// Protocol with default implementation for initing a view controller from a storyboard
protocol StoryboardInitializable {
    
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle? { get }
    
    static func makeFromStoryboard() -> Self
}

extension StoryboardInitializable where Self : UIViewController {
    
    static var storyboardName: String {
        return "Main"
    }
    
    static var storyboardBundle: Bundle? {
        return nil
    }
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    
    static func makeFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        return storyboard.instantiateViewController(
            withIdentifier: storyboardIdentifier) as! Self
    }
}
