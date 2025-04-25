//
//  Date+Extension.swift
//  ToDo
//
//  Created by Katerina Dev on 9.04.25.
//

import Foundation

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
