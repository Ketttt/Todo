//
//  TaskCell.swift
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
    
    private let taskTitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskDescription: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskDate: UILabel = {
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
        textStackView.addArrangedSubview(taskTitle)
        textStackView.addArrangedSubview(taskDescription)
        textStackView.addArrangedSubview(taskDate)
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
    
    func configure(task: Todo) {
        checkBox.setImage(UIImage(resource: task.completed ? .doneIcon : .circle), for: .normal)
        taskDescription.text = task.body
        taskTitle.text = task.todo
        taskDate.text = task.date.getFormattedDate(format: "dd/MM/YYYY")
        taskDescription.textColor = task.completed ? .darkGray : .white
        taskTitle.textColor = task.completed ? .darkGray : .white
        
        if task.completed {
            let text = NSAttributedString(
                string: task.todo,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.darkGray
                ]
            )
            taskTitle.attributedText = text
        } else {
            taskTitle.text = task.todo
        }
    }
    
    func defaultState() {
        let text = NSAttributedString(string: "", attributes: [:])
        taskTitle.attributedText = text
    }
    
    @objc func checkToDo(_ sender: UIButton) {
        self.actionHandler?()
    }
}
