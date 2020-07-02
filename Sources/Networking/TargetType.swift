//
//  TargetType.swift
//  Networking_Example
//
//  Created by Yassin El Mouden on 04/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public protocol TargetType {
    var path: String { get }
    var method: HTTPMethod { get }
    var typeEncoding: Encoding { get }
    var parameters: [String: Any] { get }
}
