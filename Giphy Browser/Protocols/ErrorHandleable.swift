//
//  ErrorHandleable.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/6/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

protocol ErrorHandleable: class {
    func handle(_ error: Error?)
}

extension ErrorHandleable where Self: UIViewController {
    func handle(_ error: Error?) {
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        let alert = UIAlertController(error: error)
        alert.view.tintColor = UIColor.appBlue
        present(alert, animated: true)
    }
}
