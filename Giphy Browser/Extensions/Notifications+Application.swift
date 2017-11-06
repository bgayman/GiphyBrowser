//
//  Notifications+Application.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let webserviceDidFailToConnect = Notification.Name("WebserviceDidFailToConnect")
    static let webserviceDidConnect = Notification.Name("WebserviceDidConnect")
}

extension NotificationCenter {
    @objc func when(_ name: Notification.Name, perform block: @escaping (Notification) -> ()) {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main, using: block)
    }
}
