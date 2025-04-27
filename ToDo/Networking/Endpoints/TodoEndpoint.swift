//
//  TaskEndpoint.swift
//  ToDo
//
//  Created by Katerina Dev on 6.02.25.
//

import Foundation

enum TodoEndpoint: EndpointProtocol {
    case fetchTasks
    
    var path: String {
        switch self {
        case .fetchTasks: "/todos"
        }
    }
    
    var method: String {
        switch self {
        case .fetchTasks: return "GET"
        }
    }
    
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        switch self {
        case.fetchTasks:
            return nil
        }
    }
}
