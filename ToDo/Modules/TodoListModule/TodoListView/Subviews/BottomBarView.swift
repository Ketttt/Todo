//
//  BottomBarView.swift
//  ToDo
//
//  Created by Katerina Dev on 6.02.25.
//

import UIKit

final class BottomBarView: UIView {
    
    private let todoCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = #colorLiteral(red: 0.9972637296, green: 0.8453423381, blue: 0.002636692021, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        backgroundColor = #colorLiteral(red: 0.1529409289, green: 0.1529413164, blue: 0.1615334749, alpha: 1)
        addSubview(todoCountLabel)
        addSubview(addButton)
        
        NSLayoutConstraint.activate([
            todoCountLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            todoCountLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func updateTakCount(_ count: Int) {
        todoCountLabel.text = "\(count) Задач"
    }
    
    func setAddButtonAction(target: Any, action: Selector) {
        addButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
