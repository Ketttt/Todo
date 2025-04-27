//
//  TodoDetailAssembly.swift
//  ToDo
//
//  Created by Katerina Dev on 10.02.25.
//

import Foundation

final class TodoDetailAssembly {
    
    func makeModule(todo: Todo?, output: TodoListModuleInput, isNewTodo: Bool) -> TodoDetailViewController {
        let interactor = TodoDetailInteractor()
        let view = TodoDetailViewController()
        let router = TodoDetailRouter(view)
        let presenter = TodoDetailPresenter(interactor: interactor, 
                                            router: router,
                                            view: view,
                                            todo: todo,
                                            output: output, 
                                            isNewTodo: isNewTodo)
        view.presenter = presenter
        return view
    }
}
