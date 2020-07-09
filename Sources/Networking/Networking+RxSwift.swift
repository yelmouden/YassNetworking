//
//  Networking+RxSwift.swift
//  Networking_Example
//
//  Created by Yassin El Mouden on 05/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift

public extension Networking {
    func request<T: Decodable,APIError>(
        target: TargetType,
        decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        errorAPIHandler: @escaping HandlerAPIError<APIError?>
    ) -> Observable<T>
    {
        Observable<T>.create { (observer) -> Disposable in
            let request = self.request(
                target: target,
                errorAPIHandler: errorAPIHandler,
                decodingStrategy: decodingStrategy,
                dateDecodingStrategy: dateDecodingStrategy
            ) { (result: Result<T,NetworkError>) in
                switch result {
                case let .success(element):
                    observer.onNext(element)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }

            return Disposables.create {
                request?.cancel()
            }
        }
    }
}


public extension Observable {
    func mapToResult<E>() -> Observable<Result<Element, NetworkError<E?>>> {
        self.materialize().flatMap { (event) -> Observable<Result<Element, NetworkError<E?>>> in
            switch event {
            case let .next(element):
                return .just(.success(element))
            case let .error(error):
                guard let networkError = error as? NetworkError<E?> else { return .empty() }
                return .just(.failure(networkError))
            case .completed:
                return .empty()
            }
        }
    }
}


extension Observable where Element: ResultType {
    var value: Observable<Element.Success> {
        map { guard let element = $0.value  else { return nil }
            return element
        }.filter{ $0 != nil }
            .map{ $0! }
    }

    var error: Observable<Element.Failure> {
        map {
            guard let element = $0.error  else { return nil }
            return element
        }.filter{ $0 != nil }
            .map{ $0! }
    }
}
