//
//  NetworkDispatcher.swift
//  YPCombineNetworking
//
//  Created by Henry Yiu on 10/9/2023.
//

import Combine
import Foundation

public struct NetworkDispatcher {
    
    private let urlSession: URLSession
    
    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    public func dispatch<T: Codable>(_ request: NetworkRequest<T>) -> AnyPublisher<T, NetworkError> {
        request.urlRequestPublisher
            .dataTask(on: urlSession)
            .receive(on: DispatchQueue.main)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToNetworkErrorPublisher()
    }
}

private extension Publisher where Output == URLRequest, Failure == NetworkError {
    func dataTask(on urlSession: URLSession) -> AnyPublisher<Data, NetworkError> {
        self.flatMap { request in
            urlSession.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global())
                .tryMap { data, response in
                    guard let urlResponse = response as? HTTPURLResponse else {
                        throw NetworkError.unknownError
                    }
                    
                    guard 200...299 ~= urlResponse.statusCode else {
                        throw NetworkError.responseError(urlResponse.statusCode)
                    }
                    
                    return data
                }
                .eraseToNetworkErrorPublisher()
        }
        .eraseToAnyPublisher()
    }
}
