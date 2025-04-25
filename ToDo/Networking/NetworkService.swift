//
//  NetworkService.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: EndpointProtocol) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    func request<T>(endpoint: EndpointProtocol) async throws -> T where T : Decodable {
        guard let urlRequest = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest.outLogger())
    
        urlRequest.inLogger(data: data, response: response as? HTTPURLResponse)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
