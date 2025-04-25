//
//  Todos.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import Foundation
import CoreData

// MARK: - Todos
struct Todos: Codable {
    let todos: [Todo]
    let total, skip, limit: Int
}

// MARK: - Todo
struct Todo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    var body: String?
    var date: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    
    enum CodingKeys: String, CodingKey {
        case id, todo, completed
    }
}
