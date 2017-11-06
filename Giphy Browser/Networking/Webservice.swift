//
//  Webservice.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

enum WebserviceError: Error {
    case noData
    case parseError
    case invalidURL
}

/// Small wrapper around URLSession
struct Webservice {
    
    static func dataTask<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T>) -> Void) {
        NetworkActivityIndicatorManager.shared.incrementIndicatorCount()
        URLSession.shared.configuration.timeoutIntervalForRequest = 30.0
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                NetworkActivityIndicatorManager.shared.decrementIndicatorCount()
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    let code = (error as NSError?)?.code
                    if code == NSURLErrorNotConnectedToInternet ||
                        code == NSURLErrorCannotConnectToHost ||
                        code == NSURLErrorTimedOut ||
                        code == NSURLErrorNetworkConnectionLost {
                        NotificationCenter.default.post(name: .webserviceDidFailToConnect, object: nil)
                    }
                    completion(.error(error: error!))
                }
                
                return
            }
            NotificationCenter.default.post(name: .webserviceDidConnect, object: nil)
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.error(error: WebserviceError.noData))
                }
                
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(Giphy.dateFormatter)
                let object = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response: object))
                }
            }
            catch {
                print(error)
                DispatchQueue.main.async {
                    completion(.error(error: error))
                }
            }
        }.resume()
    }
    
    static func dataTask<T: Decodable>(with url: URL, completion: @escaping (Result<T>) -> Void) {
        let request = URLRequest(url: url)
        Webservice.dataTask(with: request, completion: completion)
    }
}
