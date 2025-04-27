//
//  UILabel+Extension.swift
//  ToDo
//
//  Created by Katerina Dev on 27.04.25.
//

import UIKit

extension UILabel {
    static func make(fontSize: CGFloat, color: UIColor, lines: Int = 1, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: fontSize)
        label.textColor = color
        label.numberOfLines = lines
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
