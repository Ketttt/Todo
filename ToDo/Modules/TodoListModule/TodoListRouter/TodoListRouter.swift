//
//  ToDoRouter.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import UIKit

protocol IToDoRouter {
    func openTaskDetail(todo: Todo?, output: TodoListModuleInput, isNewTask: Bool)
}

final class TodoListRouter {
    
    var viewController: UIViewController?
    
    init(_ nav: UIViewController?) {
        self.viewController = nav
    }
}

extension TodoListRouter: IToDoRouter {
    
    func openTaskDetail(todo: Todo?, output: TodoListModuleInput, isNewTask: Bool) {
        guard let navigation = viewController?.navigationController else { return }
        let taskDetail = TodoDetailAssembly().makeModule(todo: todo, output: output, isNewTask: isNewTask)
        navigation.pushViewController(taskDetail, animated: true)
    }
}
