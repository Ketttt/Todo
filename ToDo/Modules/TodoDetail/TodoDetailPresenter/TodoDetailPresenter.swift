//
//  TodoDetailPresenter.swift
//  ToDo
//
//  Created by Katerina Dev on 10.02.25.
//

import Foundation

protocol ITodoDetailPresenter {
    func onBackButtonTapped()
    var todo: Todo? { get set }
    func updateTodo(todo: String?, body: String?) async
    func addTodo(todo: String?, body: String?) async
    var isNewTodo: Bool { get set }
}

final class TodoDetailPresenter {
    var interactor: ITodoDetailInteractor
    var router: ITodoDetailRouter
    var view: ITodoDetailViewController
    var todo: Todo?
    var output: TodoListModuleInput
    
    var isNewTodo: Bool
    
    init(interactor: ITodoDetailInteractor,
         router: ITodoDetailRouter,
         view: ITodoDetailViewController,
         todo: Todo?,
         output: TodoListModuleInput,
         isNewTodo: Bool) {
        self.interactor = interactor
        self.router = router
        self.view = view
        self.todo = todo
        self.output = output
        self.isNewTodo = isNewTodo
    }
}

extension TodoDetailPresenter: ITodoDetailPresenter {
    
    func onBackButtonTapped() {
        router.popToToDoList()
    }
    
    func updateTodo(todo: String?, body: String?) async {
        do {
            guard let id = self.todo?.id else { return }
            guard let updatedTodo = try CoreDataManager.editTodo(id: id, todo: todo, body: body)
            else { return }
            
            await output.refreshUpdatedTodo(todo: updatedTodo)
        } catch CoreDataError.objectNotFound(let id) {
            await view.showError(message: "Задача с ID \(id) не найдена")
        } catch CoreDataError.saveFailed(let error) {
            await view.showError(message: "Не удалось сохранить изменения: \(error.localizedDescription)")
        } catch {
            await view.showError(message: "Не удалось сохранить изменения")
        }
    }
    
    func addTodo(todo: String?, body: String?) async {
        do {
            guard let addTodo = try CoreDataManager.addTodo(title: todo, body: body)
            else { return }
            await output.addNewTodo(todo: addTodo)
        } catch CoreDataError.saveFailed(let error) {
            await view.showError(message: "Не удалось добавить новую todo: \(error.localizedDescription)")
        } catch {
            await view.showError(message: "Не удалось сохранить изменения")
        }
    }
}
