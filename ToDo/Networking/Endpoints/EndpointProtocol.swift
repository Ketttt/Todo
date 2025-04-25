//
//  EndpointProtocol.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import Foundation

protocol EndpointProtocol {
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var urlRequest: URLRequest? { get }
}

extension EndpointProtocol {
    var baseURL: String { "https://dummyjson.com" }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: baseURL + path) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
