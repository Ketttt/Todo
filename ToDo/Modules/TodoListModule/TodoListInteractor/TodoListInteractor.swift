//
//  ToDoInteractor.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import Foundation

protocol IToDoInteractor: AnyObject {
    func fetchTodos() async throws -> Todos
}

final class TodoListInteractor {

    private let apiClient: APIClientProtocol
    init(apiClient: APIClientProtocol = APIClient()){
        self.apiClient = apiClient
    }
}

extension TodoListInteractor: IToDoInteractor {
    
    func fetchTodos() async throws -> Todos {
        return try await apiClient.fetchTodos()
    }
}

