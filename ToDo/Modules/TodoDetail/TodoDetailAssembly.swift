//
//  TaskDetailAssembly.swift
//  ToDo
//
//  Created by Katerina Dev on 10.02.25.
//

import Foundation

final class TodoDetailAssembly {
    
    func makeModule(todo: Todo?, output: TodoListModuleInput, isNewTask: Bool) -> TodoDetailViewController {
        let interactor = TaskDetailInteractor()
        let view = TodoDetailViewController()
        let router = TodoDetailRouter(view)
        let presenter = TodoDetailPresenter(interactor: interactor, 
                                            router: router,
                                            view: view,
                                            todo: todo,
                                            output: output, 
                                            isNewTask: isNewTask)
        view.presenter = presenter
        return view
    }
}
