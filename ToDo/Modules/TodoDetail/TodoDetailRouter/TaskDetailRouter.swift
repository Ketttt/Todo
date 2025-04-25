//
//  TaskDetailRouter.swift
//  ToDo
//
//  Created by Katerina Dev on 10.02.25.
//

import UIKit

protocol ITodoDetailRouter {
    func popToToDoList()
}

final class TodoDetailRouter {
    
    var viewController: UIViewController?
    
    init(_ nav: UIViewController?) {
        self.viewController = nav
    }
}

extension TodoDetailRouter: ITodoDetailRouter {
    func popToToDoList() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
