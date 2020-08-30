//
//  Networking.swift
//  Networking_Example
//
//  Created by Yassin El Mouden on 04/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public class Networking : NetworkProtocol {
    public let requestManager: RequestManager
    public let cacheManager: CacheManagerProtocol

    public init(requestManager: RequestManager = URLSession.shared, cacheManager: CacheManagerProtocol = CacheManager()) {
        self.requestManager = requestManager
        self.cacheManager = cacheManager
    }

    public func loadFromCache<T>(target: TargetType) -> T? where T : Decodable {
        return cacheManager.loadFromCache(target: target)
    }

    public func request<T: Decodable, APIError>(
        target: TargetType,
        errorAPIHandler: @escaping HandlerAPIError<APIError?>,
        completion: @escaping (Result<T, NetworkError<APIError?>>) -> Void)
        -> Request?
    {
        guard let request = prepareRequest(target: target) else {
            completion(.failure(NetworkError.invalidRequest(target.path)))
            return nil
        }

        return requestManager.request(request: request) { data, response, error in
            switch (data, response, error)  {
            case let (.none, _, .some(error)):
                completion(.failure(.codeError((error as NSError).code)))
                return
            case (.some(let data), _, .some(let error)):
                guard let apiError = errorAPIHandler(error, data) else {
                    completion(.failure(.unknown))
                    return
                }
                completion(.failure(.apiError(apiError)))
                return
            case let (.some(data), _, .none):
                self.cacheManager.saveInCache(data: data, target: target)

                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = target.decodingStrategy
                jsonDecoder.dateDecodingStrategy = target.dateDecodingStrategy
                do {
                    let object = try jsonDecoder.decode(T.self, from: data)
                    completion(.success(object))
                }catch {
                    completion(.failure(.parsingError(error as! DecodingError)))
                }

                return
            default: break
            }
        }
    }
}

private extension Networking {
    func decode<T: Decodable>(
        data: Data,
        decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) throws -> T
    {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = decodingStrategy
        jsonDecoder.dateDecodingStrategy = dateDecodingStrategy

        return try jsonDecoder.decode(T.self, from: data)
    }
}

private extension Networking {
    func prepareRequest(target: TargetType) -> URLRequest? {
        guard let url = URL(string: target.path) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue.uppercased()

        if target.typeEncoding == .url {
            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return nil
            }

            components.queryItems = target.parameters.reduce([]) { (queryItems, param) -> [URLQueryItem] in
                let (key, value) = param
                var items = queryItems
                let valueParam = String(describing: value)

                items.append(URLQueryItem(name: key, value: valueParam))
                return items
            }

            request.url = components.url
        }else {
            guard let data = try? JSONSerialization.data(withJSONObject: target.parameters, options: .prettyPrinted) else { return nil }
            request.httpBody = data
        }

        return request
    }
}
