//
//  UITextView+Extension.swift
//  ToDo
//
//  Created by Katerina Dev on 21.04.25.
//

import UIKit

extension UITextView {
    enum PlaceholderState {
        case visible(String)
        case hidden
    }
    
    func setPlaceholder(_ state: PlaceholderState) {
        switch state {
        case .visible(let text):
            self.text = text
            self.textColor = .lightGray
        case .hidden:
            self.text = ""
            self.textColor = .white
        }
    }
    
    var isShowingPlaceholder: Bool {
        return textColor == .lightGray
    }
}
