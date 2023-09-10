//
//  NetworkError.swift
//  YPCombineNetworking
//
//  Created by Henry Yiu on 10/9/2023.
//

import Combine
import Foundation

public enum NetworkError: Error {
    case invalidPath
    case responseError(_ statusCode: Int)
    case urlError(_ error: URLError)
    case decodingError(_ description: String)
    case unknownError
}

extension Publisher where Failure == Error {
    func eraseToNetworkErrorPublisher() -> AnyPublisher<Output, NetworkError> {
        self.mapError { error in
            switch error {
            case let networkError as NetworkError:
                return networkError
                
            case let urlError as URLError:
                return .urlError(urlError)
                
            case is Swift.DecodingError:
                return .decodingError(error.localizedDescription)
                
            default:
                return .unknownError
            }
        }
        .eraseToAnyPublisher()
    }
}
