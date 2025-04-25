//
//  UserDefaults+Extension.swift
//  ToDo
//
//  Created by Katerina Dev on 13.04.25.
//

import Foundation

extension UserDefaults {
    
    var isFirstLaunch: Bool {
        get {
            !bool(forKey: "hasLaunchedBefore")
        } set {
            set(!newValue, forKey: "hasLaunchedBefore")
        }
    }
}
