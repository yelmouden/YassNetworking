//
//  File.swift
//  
//
//  Created by Yassin El Mouden on 01/07/2020.
//

import Foundation
import Combine
import ComposableArchitecture

extension Networking {
    public func request<T: Decodable,APIError>(
           target: TargetType,
           decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
           errorAPIHandler: @escaping HandlerAPIError<APIError?>
       )
        -> Effect<Result<T, NetworkError<APIError?>>, Never>
    {
        let publisher: AnyPublisher<Result<T, NetworkError<APIError?>>, Never> = self.request(
            target: target,
            decodingStrategy: decodingStrategy,
            errorAPIHandler: errorAPIHandler
        )

        return publisher.eraseToEffect()
    }
}
