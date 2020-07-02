//
//  Networking.swift
//  Networking_Example
//
//  Created by Yassin El Mouden on 04/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public class Networking : NetworkProtocol {
    public var manager: Manager

    public init(manager: Manager = URLSession.shared) {
        self.manager = manager
    }

    public func request<T: Decodable, APIError>(
        target: TargetType,
        errorAPIHandler: @escaping HandlerAPIError<APIError?>,
        decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        completion: @escaping (Result<T, NetworkError<APIError?>>) -> Void)
        -> Request?
    {
        guard let request = prepareRequest(target: target) else {
            completion(.failure(NetworkError.invalidRequest(target.path)))
            return nil
        }

        return manager.request(request: request) { data, response, error in
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
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = decodingStrategy

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

extension Networking {
    private func prepareRequest(target: TargetType) -> URLRequest? {
        guard let url = URL(string: target.path) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue.uppercased()

        if target.typeEncoding == .URL {
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
