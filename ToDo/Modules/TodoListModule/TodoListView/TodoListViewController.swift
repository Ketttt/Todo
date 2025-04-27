//
//  ToDoViewController.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import UIKit

//MARK: - IToDoView Protocol
@MainActor
protocol ITodoListView {
    func showTodoList(_ todos: [Todo])
    func showTodoAtRow(_ todo: Todo)
    func didDeleteTodo(_ todo: Todo)
    func refreshUpdatedTodo(todo: Todo)
    func addNewTodo(todo: Todo)
    func showSearchResults(_ todos: [Todo])
    func showError(message: String)
}

//MARK: - ToDoViewController
final class TodoListViewController: UIViewController {
    
    //MARK: - Properties
    var presenter: ITodoListPresenter?
    private var todos: [Todo] = []
    private var filteredTodos: [Todo] = []
    private var currentTodos: [Todo] {
        searchController.isActive ? filteredTodos : todos
    }
    
    //MARK: - UI Elements
    private let bottomBar = BottomBarView()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        tableView.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск задач"
        searchController.searchBar.searchTextField.textColor = .white
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
                    string: "Поиск задач",
                    attributes: [.foregroundColor: UIColor.lightGray]
                )
        searchController.searchBar.searchTextField.leftView?.tintColor = .lightGray
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = UIColor.darkGray
        return searchController
    }()
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        definesPresentationContext = true
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        setupUI()
        setupSearchController()
        presenter?.loadTodos()
        setupTapGesture()
        searchController.searchBar.searchTextField.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        if searchController.isActive {
            searchController.searchBar.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
    }

    @objc private func searchTextChanged() {
        searchController.searchBar.searchTextField.textColor = .white
    }
    
    //MARK: - Private methods
    private func configureNavBar() {
        title = "Задачи"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(tableView)
        view.addSubview(bottomBar)
        tableView.delegate = self
        tableView.dataSource = self
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.safeAreaLayoutGuide.owningView?.backgroundColor = #colorLiteral(red: 0.1529409289, green: 0.1529413164, blue: 0.1615334749, alpha: 1)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 49)
        ])
        
        bottomBar.setAddButtonAction(target: self, action: #selector(addTodoTapped))
    }
    
    @objc private func addTodoTapped() {
        presenter?.showTodoDetail(todo: nil, true)
    }
    
    private func editTodo(todo: Todo) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            if self.searchController.isActive {
                if let filteredIndex = self.filteredTodos.firstIndex(where: { $0.id == todo.id }) {
                    self.filteredTodos[filteredIndex] = todo
                    self.tableView.reloadRows(at: [IndexPath(row: filteredIndex, section: 0)], with: .fade)
                }
            } else {
                if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                    self.todos[index] = todo
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            }
        }
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTodos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        let todo = currentTodos[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(todo: todo)
        cell.backgroundColor = .black
        cell.actionHandler = { [weak self] in
            guard let self else { return }
            let todo = self.currentTodos[indexPath.row]
            presenter?.checkButtonClicked(todo)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTodo = currentTodos[indexPath.row]
        presenter?.showTodoDetail(todo: selectedTodo, false)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
            guard let self = self else {
                completionHandler(false)
                return
            }
            let todo = currentTodos[indexPath.row]
            self.presenter?.deleteTodo(todo)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = UIColor.red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let todo = self.currentTodos[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return self.makePreviewViewController(for: todo)
        }) { [weak self] _ in
            
            guard let self = self else { return UIMenu() }
            
            let edit = UIAction(
                title: "Редактировать",
                image: UIImage(resource: .edit)
            ) { _ in
                self.presenter?.showTodoDetail(todo: todo, false)
            }
            let export = UIAction(
                title: "Поделиться",
                image: UIImage(resource: .export)
            ) { _ in
                print("Tapped open")
            }
            let trash = UIAction(
                title: "Удалить",
                image: UIImage(resource: .trash)
            ) { _ in
                self.didDeleteTodo(todo)
            }
            let menu = UIMenu(title: "", children: [edit, export, trash])
            return menu
        }
    }
    
    private func makePreviewViewController(for todo: Todo) -> UIViewController {
        let previewVC = UIViewController()
        previewVC.view.backgroundColor = #colorLiteral(red: 0.1529409289, green: 0.1529413164, blue: 0.1615334749, alpha: 1)
        
        let todoCell = TodoCell(style: .default, reuseIdentifier: nil, true)
        todoCell.configure(todo: todo)
        
        previewVC.view.layer.cornerRadius = 12
        previewVC.view.layer.masksToBounds = true
        previewVC.view.clipsToBounds = true
        
        let targetWidth = UIScreen.main.bounds.width - 40
        let targetSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        let calculatedHeight = todoCell.systemLayoutSizeFitting(targetSize).height
        
        previewVC.view.addSubview(todoCell)
        
        todoCell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            todoCell.leadingAnchor.constraint(equalTo: previewVC.view.leadingAnchor),
            todoCell.trailingAnchor.constraint(equalTo: previewVC.view.trailingAnchor),
            todoCell.topAnchor.constraint(equalTo: previewVC.view.topAnchor),
            todoCell.bottomAnchor.constraint(equalTo: previewVC.view.bottomAnchor),
        ])
        
        previewVC.preferredContentSize = CGSize(
            width: targetWidth,
            height: calculatedHeight
        )
        return previewVC
    }
}

//MARK: - ITodoListView
extension TodoListViewController: ITodoListView {
    func showError(message: String) {
        let alert = UIAlertController(title: message,
                                      message: "Пожалуйста, попробуйте снова",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        )
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    func showSearchResults(_ todos: [Todo]) {
        self.filteredTodos = todos
        tableView.reloadData()
    }
    
    func didDeleteTodo(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        UIView.animate(withDuration: 0.3) {
            self.todos.remove(at: index)
            if self.searchController.isActive {
                if let filteredIndex = self.filteredTodos.firstIndex(where: { $0.id == todo.id }) {
                    self.filteredTodos.remove(at: filteredIndex)
                    self.tableView.deleteRows(at: [IndexPath(row: filteredIndex, section: .zero)], with: .left)
                }
            } else {
                self.tableView.deleteRows(at: [IndexPath(row: index, section: .zero)], with: .left)
            }
        } completion: { _ in self.tableView.reloadData() }
        self.bottomBar.updateTakCount(todos.count)
    }
    
    func showTodoAtRow(_ todo: Todo) {
        editTodo(todo: todo)
    }
    
    func showTodoList(_ todos: [Todo]) {
        self.todos = todos
        self.bottomBar.updateTakCount(todos.count)
        self.tableView.reloadData()
    }
    
    func refreshUpdatedTodo(todo: Todo) {
        editTodo(todo: todo)
    }
    
    func addNewTodo(todo: Todo) {
        todos.insert(todo, at: 0)
        if searchController.isActive {
            filteredTodos.insert(todo, at: 0)
        }
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
        self.bottomBar.updateTakCount(todos.count)
    }
}

// MARK: - UISearchResultsUpdating
extension TodoListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else { filteredTodos = []
            tableView.reloadData()
            return
        }
        
        if searchText.isEmpty {
            filteredTodos = todos
        } else {
            presenter?.searchTodo(searchText: searchText)
        }
        
        tableView.reloadData()
    }
}

// MARK: - UISearchControllerDelegate
extension TodoListViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        filteredTodos = todos
        tableView.reloadData()
    }
}
