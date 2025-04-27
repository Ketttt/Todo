//
//  TodoDetailViewController.swift
//  ToDo
//
//  Created by Katerina Dev on 10.02.25.
//

import UIKit

//MARK: - ITodoDetailViewController Protocol
@MainActor
protocol ITodoDetailView {
    func showError(message: String)
}

//MARK: - TodoDetailViewController
final class TodoDetailViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: ITodoDetailPresenter?
    
    //MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()
    
    private lazy var titleTextView = UITextView.makeTextView(fontSize: 28, isBold: true)
    private lazy var noteTextView = UITextView.makeTextView(fontSize: 16, isBold: false)
    private weak var activeTextView: UITextView?
    
    private lazy var doneButtonItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem()
        barButton.tintColor = .yellowColor
        barButton.target = self
        barButton.action = #selector(doneButtonTapped)
        barButton.title = "Готово"
        barButton.style = .done
        return barButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
    
// MARK: - Setup Methods
extension TodoDetailViewController {
    private func configureNavBar() {
        let icon = UIImageView(image: .backIcon)
        icon.tintColor = UIColor.yellowColor
        icon.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "Назад"
        label.textColor = UIColor.yellowColor
        label.font = UIFont.systemFont(ofSize: 17)
        
        let stackView = UIStackView(arrangedSubviews: [icon, label])
        stackView.axis = .horizontal
        stackView.spacing = 6
        
        let backButton = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = backButton
        navigationItem.largeTitleDisplayMode = .never
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBack))
        stackView.isUserInteractionEnabled = true
        stackView.addGestureRecognizer(tapGesture)
    }
    
    private func setupView() {
        view.backgroundColor = .black
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(views: titleTextView,
                                noteTextView)
        
        setupLayout()
        registerKeyboardNotifications()
        setupGestures()
        setupTextView()
        configureNavBar()
    }
    
    private func setupTextView() {
        titleTextView.delegate = self
        noteTextView.delegate = self
        
        if let todoText = presenter?.todo?.todo, !todoText.isEmpty {
            titleTextView.text = todoText
        } else {
            titleTextView.setPlaceholder(.visible("Enter title..."))
        }
        
        if let bodyText = presenter?.todo?.body, !bodyText.isEmpty {
            noteTextView.text = presenter?.todo?.body
        } else {
            noteTextView.setPlaceholder(.visible("Enter notes..."))
        }
    }
    
    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            noteTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            titleTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            noteTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 16),
            noteTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noteTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noteTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
}
    
// MARK: - Action Methods
extension TodoDetailViewController {
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    @objc private func onBack() {
        
        let title = (titleTextView.textColor == .lightGray) ? nil : titleTextView.text.nilIfEmpty
        let body = (noteTextView.textColor == .lightGray) ? nil : noteTextView.text.nilIfEmpty
        
        guard title != nil || body != nil else { return }
        guard let isNewTodo = presenter?.isNewTodo else { return }
        
        Task {
            if isNewTodo {
                await presenter?.addTodo(todo: title, body: body)
            } else {
                await presenter?.updateTodo(todo: title, body: body)
            }
        }
        presenter?.onBackButtonTapped()
    }
    
    // MARK: - Keyboard Notifications
    private func registerKeyboardNotifications() {
        let keyboardNotifications: [(NSNotification.Name, Selector)] = [
            (UIResponder.keyboardWillShowNotification, #selector(adjustForKeyboard)),
            (UIResponder.keyboardWillHideNotification, #selector(adjustForKeyboard))
        ]
        
        for (notification, selector) in keyboardNotifications {
            NotificationCenter.default.addObserver(
                self, selector: selector, name: notification, object: nil
            )
        }
    }
    
    @objc private func adjustForKeyboard(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        let keyboardHeight = notification.name == UIResponder.keyboardWillShowNotification ?
        keyboardFrame.height - view.safeAreaInsets.bottom : 0
        
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = keyboardHeight
            self.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
            
            if notification.name == UIResponder.keyboardWillShowNotification,
               let textView = self.activeTextView {
                let textViewFrame = textView.convert(textView.bounds, to: self.scrollView)
                self.scrollView.scrollRectToVisible(textViewFrame, animated: false)
            }
        }
    }
}

//MARK: - UITextViewDelegate
extension TodoDetailViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        navigationItem.rightBarButtonItem = doneButtonItem
        
        if textView == titleTextView && textView.textColor == .lightGray {
            textView.setPlaceholder(.hidden)
            textView.textColor = .white
        } else if textView == noteTextView && textView.textColor == .lightGray {
            textView.setPlaceholder(.hidden)
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == titleTextView && textView.text.isEmpty {
            textView.setPlaceholder(.visible("Enter title..."))
            textView.textColor = .lightGray
        } else if textView == noteTextView && textView.text.isEmpty {
            textView.setPlaceholder(.visible("Enter notes..."))
            textView.textColor = .lightGray
        }
    }
}

//MARK: - ITodoDetailView
extension TodoDetailViewController: ITodoDetailView {
    func showError(message: String) {
        let alert = UIAlertController(title: message,
                                      message: "Пожалуйста, попробуйте снова",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        )
        alert.addAction(okAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}
