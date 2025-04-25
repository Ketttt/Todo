//
//  ToDoPresenter.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import Foundation

protocol ITodoListPresenter {
    func loadTodos()
    func showTaskDetail(todo: Todo?,_ isNewTask: Bool)
    func checkButtonClicked(_ task: Todo)
    func deleteTodo(_ task: Todo)
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
                        let serverTasks = try await interactor.fetchTasks()
                        
                        let tasks = serverTasks.todos.map({
                            return $0
                        })
                        CoreDataManager.updateCoreData(with: tasks)
                        UserDefaults.standard.isFirstLaunch = false
                    }
                }
                let updatedTasks = try CoreDataManager.fetchTodoFromCoreData()
                await view.showTodoList(updatedTasks)
            } catch let error {
                print("Ошибка загрузки задач:", error.localizedDescription)
            }
        }
    }
    
    func checkButtonClicked(_ task: Todo) {
        Task {
            do {
                let updatedTask = try CoreDataManager.updateCompletedTodo(id: task.id)
                await view.showTaskAtRow(updatedTask)
            } catch CoreDataError.saveFailed(let error) {
                await view.showError(message: "Не удалось сохранить изменения: \(error.localizedDescription)")
            } catch {
                await view.showError(message: "Не удалось сохранить обновить статус Todo")
            }
        }
    }
    
    func deleteTodo(_ task: Todo) {
        Task {
            do {
                let deleteTask = try CoreDataManager.deleteTodo(id: task.id)
                await self.view.didDeleteTask(deleteTask)
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
    
    func showTaskDetail(todo: Todo?,_ isNewTask: Bool) {
        router.openTaskDetail(todo: todo, output: self, isNewTask: isNewTask)
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
