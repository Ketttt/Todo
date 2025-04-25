//
//  APIClient.swift
//  ToDo
//
//  Created by Katerina Dev on 6.02.25.
//

import Foundation

protocol APIClientProtocol {
    func fetchTasks() async throws -> Todos
}

final class APIClient: APIClientProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let networkMonitor: NetworkMonitor
    
    init(networkService: NetworkServiceProtocol = NetworkService(),
         networkMonitor: NetworkMonitor = .shared) {
        self.networkService = networkService
        self.networkMonitor = networkMonitor
    }
    
    func fetchTasks() async throws -> Todos {
        guard networkMonitor.hasInternetConnection() else {
            throw NetworkError.noInternetConnection
        }
        return try await networkService.request(endpoint: TaskEndpoint.fetchTasks)
    }
}

