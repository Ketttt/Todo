//
//  ToDoPresenter.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import Foundation

protocol ITodoListPresenter {
    func loadTodos()
    func showTodoDetail(todo: Todo?,_ isNewTodo: Bool)
    func checkButtonClicked(_ todo: Todo)
    func deleteTodo(_ todo: Todo)
    func searchTodo(searchText: String)
}

final class TodoListPresenter {
    var interactor: IToDoInteractor
    var view: ITodoListView
    var router: IToDoRouter
    
    init(interacror: IToDoInteractor, view: ITodoListView, router: IToDoRouter) {
        self.interactor = interacror
        self.view = view
        self.router = router
    }
}

extension TodoListPresenter: ITodoListPresenter {
    func loadTodos() {
        Task {
            do {
                if UserDefaults.standard.isFirstLaunch {
                    if NetworkMonitor.shared.hasInternetConnection()  {
                        let serverTodo = try await interactor.fetchTodos()
                        
                        let todo = serverTodo.todos.map({
                            return $0
                        })
                        CoreDataManager.updateCoreData(with: todo)
                        UserDefaults.standard.isFirstLaunch = false
                    }
                }
                let updatedTodos = try CoreDataManager.fetchTodoFromCoreData()
                await view.showTodoList(updatedTodos)
            } catch let error {
                print("Ошибка загрузки задач:", error.localizedDescription)
            }
        }
    }
    
    func checkButtonClicked(_ todo: Todo) {
        Task {
            do {
                let updatedTodo = try CoreDataManager.updateCompletedTodo(id: todo.id)
                await view.showTodoAtRow(updatedTodo)
            } catch CoreDataError.saveFailed(let error) {
                await view.showError(message: "Не удалось сохранить изменения: \(error.localizedDescription)")
            } catch {
                await view.showError(message: "Не удалось сохранить обновить статус Todo")
            }
        }
    }
    
    func deleteTodo(_ todo: Todo) {
        Task {
            do {
                let deleteTodo = try CoreDataManager.deleteTodo(id: todo.id)
                await self.view.didDeleteTodo(deleteTodo)
            } catch CoreDataError.saveFailed(let error) {
                await view.showError(message: "Не удалось сохранить изменения: \(error.localizedDescription)")
            } catch {
                await view.showError(message: "Не удалось удалить Todo")
            }
        }
    }

    func searchTodo(searchText: String) {
        Task {
            do {
                let notes = try CoreDataManager.searchTodo(with: searchText)
                guard !notes.isEmpty else {
                    await self.view.showSearchResults([])
                    return
                }
                await view.showSearchResults(notes)
            } catch {
                await view.showError(message: "Не удалось совершить поиск")
            }
        }
    }
    
    func showTodoDetail(todo: Todo?,_ isNewTodo: Bool) {
        router.openTodoDetail(todo: todo, output: self, isNewTodo: isNewTodo)
    }
}

extension TodoListPresenter: TodoListModuleInput {
    func addNewTodo(todo: Todo) {
        view.addNewTodo(todo: todo)
    }
    
    func refreshUpdatedTodo(todo: Todo) {
        view.refreshUpdatedTodo(todo: todo)
    }
}
