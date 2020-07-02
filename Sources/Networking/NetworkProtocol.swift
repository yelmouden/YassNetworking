//
//  NetworkProtocol.swift
//  Networking_Example
//
//  Created by Yassin El Mouden on 03/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public typealias HandlerAPIError<E> = (Error, Data) -> E?

public enum HTTPMethod: String {
    case get
    case post
}

public enum Encoding {
    case JSON
    case URL
}

public enum NetworkError<T>: Error {
    case invalidRequest(String)
    case apiError(T)
    case codeError(Int)
    case parsingError(DecodingError)
    case unknown
}

public protocol Request {
    func cancel()
}

public protocol ResultType {
    associatedtype Success
    associatedtype Failure

    var value: Success? { get }
    var error: Failure? { get }
}

extension Result: ResultType {
    public var value: Success? { try? get() }

    public var error: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}

public protocol Manager {
    func request(
        request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> Request?
}


public protocol NetworkProtocol {
    var manager: Manager { get }

    func request<T: Decodable, APIError>(
        target: TargetType,
        errorAPIHandler: @escaping HandlerAPIError<APIError?>,
        decodingStrategy: JSONDecoder.KeyDecodingStrategy,
        completion: @escaping (Result<T, NetworkError<APIError?>>) -> Void
    ) -> Request?
}

