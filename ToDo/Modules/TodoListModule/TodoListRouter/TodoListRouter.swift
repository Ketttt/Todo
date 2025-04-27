//
//  ToDoRouter.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import UIKit

protocol IToDoRouter {
    func openTodoDetail(todo: Todo?, output: TodoListModuleInput, isNewTodo: Bool)
}

final class TodoListRouter {
    
    var viewController: UIViewController?
    
    init(_ nav: UIViewController?) {
        self.viewController = nav
    }
}

extension TodoListRouter: IToDoRouter {
    
    func openTodoDetail(todo: Todo?, output: TodoListModuleInput, isNewTodo: Bool) {
        guard let navigation = viewController?.navigationController else { return }
        let todoDetail = TodoDetailAssembly().makeModule(todo: todo, output: output, isNewTodo: isNewTodo)
        navigation.pushViewController(todoDetail, animated: true)
    }
}
