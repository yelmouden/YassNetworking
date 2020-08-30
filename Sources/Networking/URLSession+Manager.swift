//
//  URLSession+Manager.swift
//  Networking_Example
//
//  Created by Yassin El Mouden on 04/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

extension URLSessionTask: Request {}

extension URLSession: RequestManager {
    public func request(
        request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> Request?
    {
        let task = dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}
