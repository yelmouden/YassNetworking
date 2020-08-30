//
//  CacheManager.swift
//  Networking
//
//  Created by Yassin El Mouden on 30/08/2020.
//  Copyright © 2020 Yassin El Mouden. All rights reserved.
//

import Foundation

public protocol CacheManagerProtocol {
    func saveInCache(data: DataProtocol, target: TargetType)
    func loadFromCache<T: Decodable>(target: TargetType) -> T?
}

public protocol DataProtocol {
    func write(to url: URL, options: Data.WritingOptions) throws
}

extension Data: DataProtocol {}

public final class CacheManager: CacheManagerProtocol {
    public init() {}
    
    public func saveInCache(data: DataProtocol, target: TargetType) {
        guard target.shouldCache, let pathForCache = target.pathForCache else { return }

        let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fullPath = baseURL.appendingPathComponent(pathForCache)
        do {
            try data.write(to: fullPath, options: [])
        } catch {
            print("error during save")
        }
    }

    public func loadFromCache<T>(target: TargetType) -> T? where T : Decodable {
        guard target.shouldCache, let pathForCache = target.pathForCache else { return nil }

        let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
         let fullPath = baseURL.appendingPathComponent(pathForCache)

        guard let data = try? Data(contentsOf: fullPath) else { return nil }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = target.decodingStrategy
        jsonDecoder.dateDecodingStrategy = target.dateDecodingStrategy

        guard let object = try? jsonDecoder.decode(T.self, from: data) else { return nil }

        return object
    }

    
}
