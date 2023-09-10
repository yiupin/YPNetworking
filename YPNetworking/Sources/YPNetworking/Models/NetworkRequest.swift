//
//  NetworkRequest.swift
//  YPCombineNetworking
//
//  Created by Henry Yiu on 10/9/2023.
//

import Combine
import Foundation

public struct NetworkRequest<T: Codable> {
    public var path: String
    public var method: HTTPMethod
    public var parameters: [String: String]?
    public var type: T.Type
    
    public init(
        path: String,
        method: HTTPMethod,
        parameters: [String: String]? = nil,
        type: T.Type
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.type = type
    }
}

extension NetworkRequest {
    var urlRequestPublisher: AnyPublisher<URLRequest, NetworkError> {
        Just(self)
            .tryMap { networkRequest -> URLRequest in
                guard var components = URLComponents(string: networkRequest.path) else {
                    throw NetworkError.invalidPath
                }
                components.queryItems = networkRequest.parameters?.map { URLQueryItem(name: $0, value: $1) }
                
                guard let url = components.url else {
                    throw NetworkError.invalidPath
                }
                
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = networkRequest.method.rawValue
                
                return urlRequest
            }
            .eraseToNetworkErrorPublisher()
    }
}
