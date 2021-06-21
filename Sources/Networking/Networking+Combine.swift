//
//  Networking+Combine.swift
//  Networking_Example
//
//  Created by Yassin El Mouden on 17/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Combine

public extension NetworkProtocol {
    func request<T: Decodable,APIError>(
        target: TargetType,
        errorAPIHandler: @escaping HandlerAPIError<APIError?>
    )
    -> AnyPublisher<Result<T, NetworkError<APIError?>>, Never>
    {
        var request: Request?
        
        return Deferred {
            Future<Result<T, NetworkError<APIError?>>, Never> { promise in
                request = self.request(
                target: target,
                errorAPIHandler: errorAPIHandler
                ) { (result: Result<T,NetworkError>) in
                    promise(.success(result))
                }
            }
        }.handleEvents(receiveCancel: {
            request?.cancel()
        })
        .eraseToAnyPublisher()
    }
}
