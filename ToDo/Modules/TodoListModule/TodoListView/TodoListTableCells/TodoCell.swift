//
//  TodoCell.swift
//  ToDo
//
//  Created by Katerina Dev on 5.02.25.
//

import UIKit
import UIKit

final class TodoCell: UITableViewCell {
    
    var actionHandler: (() -> ())?
    
    private var textLeadingConstraintWithCheckbox: NSLayoutConstraint!
    private var textLeadingConstraintWithoutCheckbox: NSLayoutConstraint!
    
    //MARK: - UI Elements
    private let todoTitle = UILabel.make(fontSize: 16, color: .white, lines: 1)
    private let todoDescription = UILabel.make(fontSize: 12, color: .white, lines: 2, alignment: .justified)
    private let todoDate = UILabel.make(fontSize: 12, color: .darkGray)
    
    private lazy var checkBox: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(checkToDo), for: .touchUpInside)
        return button
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todoTitle, todoDescription, todoDate])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        defaultState()
    }
    
    private func setUp() {
        contentView.addSubview(checkBox)
        contentView.addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkBox.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            checkBox.widthAnchor.constraint(equalToConstant: 24),
            checkBox.heightAnchor.constraint(equalToConstant: 24),
            
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        textLeadingConstraintWithCheckbox = textStackView.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 8)
        textLeadingConstraintWithoutCheckbox = textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        textLeadingConstraintWithCheckbox.isActive = true
    }
    
    func configure(todo: Todo, isMenu: Bool) {
        checkBox.isHidden = isMenu
        
        textLeadingConstraintWithCheckbox.isActive = !isMenu
        textLeadingConstraintWithoutCheckbox.isActive = isMenu
        
        todoDescription.text = todo.body
        todoDate.text = todo.date.getFormattedDate(format: "dd/MM/YYYY")
        
        if todo.completed {
            let attributed = NSAttributedString(
                string: todo.todo,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.darkGray
                ]
            )
            todoTitle.attributedText = attributed
            todoDescription.textColor = .darkGray
        } else {
            todoTitle.attributedText = nil
            todoTitle.text = todo.todo
            todoTitle.textColor = .white
            todoDescription.textColor = .white
        }
        
        checkBox.setImage(UIImage(resource: todo.completed ? .doneIcon : .circle), for: .normal)
    }
    
    func defaultState() {
        todoTitle.attributedText = nil
        todoTitle.text = nil
        todoDescription.text = nil
        todoDate.text = nil
    }
    
    @objc private func checkToDo() {
        actionHandler?()
    }
}
