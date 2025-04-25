//
//  UIView+Extensions.swift
//  ToDo
//
//  Created by Katerina Dev on 13.02.25.
//

import UIKit

extension UIView {
    func addSubviews(views: UIView...) {
        for view in views {
            self.addSubview(view)
        }
    }
}
