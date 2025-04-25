//
//  ToDoAssembly.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import Foundation

@MainActor
protocol TodoListModuleInput {
    func refreshUpdatedTodo(todo: Todo) 
    func addNewTodo(todo: Todo)
}

final class TodoListAssembly {
    
    func makeModule() -> TodoListViewController {
        let interactor = TodoListInteractor()
        let view = TodoListViewController()
        let router = TodoListRouter(view)
        let presenter = TodoListPresenter(interacror: interactor,
                                      view: view,
                                      router: router)
        view.presenter = presenter
        return view
    }
}
