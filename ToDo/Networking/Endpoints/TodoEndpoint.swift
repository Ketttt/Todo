//
//  TodoEndpoint.swift
//  ToDo
//
//  Created by Katerina Dev on 6.02.25.
//

import Foundation

enum TodoEndpoint: EndpointProtocol {
    case fetchTodos
    
    var path: String {
        switch self {
        case .fetchTodos: "/todos"
        }
    }
    
    var method: String {
        switch self {
        case .fetchTodos: return "GET"
        }
    }
    
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        switch self {
        case.fetchTodos:
            return nil
        }
    }
}
