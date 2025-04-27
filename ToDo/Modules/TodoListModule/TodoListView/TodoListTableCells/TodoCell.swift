//
//  TodoCell.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import UIKit

final class TodoCell: UITableViewCell {
    
    var actionHandler: (() -> ())?
    private let isMenu: Bool
    
    private let checkBox: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(checkToDo), for: .touchUpInside)
        return button
    }()
    
    private let todoTitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let todoDescription: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let todoDate: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textStackView: UIStackView = {
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false
        return textStack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.isMenu = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?,_ isMenu: Bool = false) {
        self.isMenu = isMenu
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        defaultState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        textStackView.addArrangedSubview(todoTitle)
        textStackView.addArrangedSubview(todoDescription)
        textStackView.addArrangedSubview(todoDate)
        self.contentView.addSubview(textStackView)
        if !isMenu {
            self.contentView.addSubview(checkBox)
        }
        
        let constr = [
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkBox.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            checkBox.widthAnchor.constraint(equalToConstant: 24),
            checkBox.heightAnchor.constraint(equalToConstant: 24)
        ]
        
        let mainConstraints = [
            textStackView.leadingAnchor.constraint(equalTo: isMenu ? contentView.leadingAnchor : checkBox.trailingAnchor, constant: 8),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ]
        
        NSLayoutConstraint.activate(isMenu ? mainConstraints : constr + mainConstraints)
    }
    
    func configure(todo: Todo) {
        checkBox.setImage(UIImage(resource: todo.completed ? .doneIcon : .circle), for: .normal)
        todoDescription.text = todo.body
        todoTitle.text = todo.todo
        todoDate.text = todo.date.getFormattedDate(format: "dd/MM/YYYY")
        todoDescription.textColor = todo.completed ? .darkGray : .white
        todoTitle.textColor = todo.completed ? .darkGray : .white
        
        if todo.completed {
            let text = NSAttributedString(
                string: todo.todo,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.darkGray
                ]
            )
            todoTitle.attributedText = text
        } else {
            todoTitle.text = todo.todo
        }
    }
    
    func defaultState() {
        let text = NSAttributedString(string: "", attributes: [:])
        todoTitle.attributedText = text
    }
    
    @objc func checkToDo(_ sender: UIButton) {
        self.actionHandler?()
    }
}
