//
//  File.swift
//  
//
//  Created by Yassin El Mouden on 01/07/2020.
//

import Foundation
import Combine
import ComposableArchitecture

public extension Networking {
    func request<T: Decodable,APIError>(
           target: TargetType,
           decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
           dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
           errorAPIHandler: @escaping HandlerAPIError<APIError?>
       )
        -> Effect<Result<T, NetworkError<APIError?>>, Never>
    {
        let publisher: AnyPublisher<Result<T, NetworkError<APIError?>>, Never> = self.request(
            target: target,
            decodingStrategy: decodingStrategy,
            dateDecodingStrategy: dateDecodingStrategy,
            errorAPIHandler: errorAPIHandler
        )

        return publisher.eraseToEffect()
    }
}
