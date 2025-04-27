//
//  CoreDataManager.swift
//  ToDo
//
//  Created by Katerina Dev on 17.02.25.
//

import Foundation
import CoreData

enum CoreDataError: Error {
    case fetchFailed
    case editTodoFailed
    case addTodoFailed
    case searchTodoFailed
    case objectNotFound(id: Int)
    case saveFailed(error: Error)
    case invalidId
}

final class CoreDataManager {
    
    static var context: NSManagedObjectContext {
        let persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "ToDo")
            let description = container.persistentStoreDescriptions.first
            description?.shouldMigrateStoreAutomatically = true
            description?.shouldInferMappingModelAutomatically = true
            container.loadPersistentStores { storeDescription, error in
                if let error = error {
                    fatalError("Ошибка загрузки Core Data: \(error)")
                }
            }
            return container
        }()
        return persistentContainer.viewContext
    }
}

extension CoreDataManager {
    
    static func editTodo(id: Int, todo: String?, body: String?) throws -> Todo? {
        let context = CoreDataManager.context
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

            let notes = try context.fetch(fetchRequest)
            guard let note = notes.first else {
                throw CoreDataError.objectNotFound(id: id)
            }
            
            note.body = body
            note.title = todo
        do {
            try context.save()
        } catch {
            throw CoreDataError.saveFailed(error: error)
        }
        
        let todo = Todo(
            id: Int(note.id),
            todo: note.title ?? "",
            completed: note.completed,
            body: note.body,
            date: .now)
        return todo
    }
    
    static func updateCoreData(with newTodos: [Todo]) {
        let context = CoreDataManager.context
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        do {
            let existingNotes = try context.fetch(fetchRequest)
            let existingIDs = Array(existingNotes.map { $0.id })
            
            for todo in newTodos {
                if !existingIDs.contains(Int64(todo.id)) {
                    let note = Note(context: context)
                    note.id = Int64(todo.id)
                    note.title = todo.todo
                    note.body = todo.body
                    note.completed = todo.completed
                    note.date = todo.date
                } else {
                    print("Задача уже существует: \(todo.id)")
                }
            }
            try context.save()
        } catch {
            print("Ошибка обновления Core Data: \(error)")
        }
    }
    
    static func updateCompletedTodo(id: Int) throws -> Todo {
        let context = CoreDataManager.context
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        let notes = try context.fetch(fetchRequest)
        
        guard let note = notes.first else {
            throw CoreDataError.objectNotFound(id: id)
        }
        note.completed.toggle()
        do {
            let todo = Todo(
                id: Int(note.id),
                todo: note.title ?? "",
                completed: note.completed,
                body: note.body,
                date: .now)
            try context.save()
            return todo
        } catch {
            throw CoreDataError.saveFailed(error: error)
        }
        
//        return todo
    }
    
    static func deleteTodo(id: Int) throws -> Todo {
        let context = CoreDataManager.context
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        guard let note = try context.fetch(fetchRequest).first else {
            throw CoreDataError.objectNotFound(id: id)
        }
        let deletedTodo = Todo(
            id: Int(note.id),
            todo: note.title ?? "",
            completed: note.completed,
            body: note.body ?? ""
        )
        do {
            context.delete(note)
            try context.save()
        } catch {
            throw CoreDataError.saveFailed(error: error)
        }
        return deletedTodo
    }
    
    static func addTodo(title: String?, body: String?, completed: Bool = false) throws -> Todo? {
        
        let context = CoreDataManager.context
        let note = Note(context: context)
        let hexPart = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(4))
        note.id = Int64(hexPart, radix: 16) ?? 0
        
        note.title = title
        note.body = body
        note.completed = completed
        note.date = Date()
        do {
            let newTodo = Todo(id: Int(note.id),
                               todo: note.title ?? "",
                               completed: note.completed,
                               body: note.body ?? "",
                               date: .now)
            
            try context.save()
            return newTodo
        } catch {
            throw CoreDataError.saveFailed(error: error)
        }
        
    }
    
    static func fetchTodoFromCoreData() throws -> [Todo] {
        let context = CoreDataManager.context
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescription = NSSortDescriptor(key: #keyPath(Note.date), ascending: false)
        fetchRequest.sortDescriptors = [sortDescription]
        
        do {
            let notes = try context.fetch(fetchRequest)
            
            let todos = notes.map { note in
                Todo(id: Int(note.id),
                        todo: note.title ?? "",
                        completed: note.completed,
                        body: note.body)
            }
            
            let newTodos = todos.map { $0 }
            print("newTodos = \(newTodos)")
            return newTodos
        } catch {
            throw CoreDataError.fetchFailed
        }
    }
    
    static func searchTodo(with searchText: String) throws -> [Todo] {
        
        let context = CoreDataManager.context
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        let predicate1 = NSPredicate(format: "title CONTAINS %@", searchText)
        let predicate2 = NSPredicate(format: "body CONTAINS %@", searchText)
        
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
        
        do {
            let notes = try context.fetch(fetchRequest)
            if searchText.isEmpty {
                return []
            }
            
            let todos = notes.map { note in
                Todo(id: Int(note.id),
                        todo: note.title ?? "",
                        completed: note.completed,
                        body: note.body)
            }
            
            let newTodos = todos.map { $0 }
            return newTodos
        } catch {
            throw CoreDataError.searchTodoFailed
        }
    }
}
