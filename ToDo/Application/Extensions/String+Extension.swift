//
//  String+Extension.swift
//  ToDo
//
//  Created by Katerina Dev on 21.04.25.
//

import Foundation

extension String {
    var nilIfEmpty: String? {
        return isEmpty ? nil : self
    }
}
