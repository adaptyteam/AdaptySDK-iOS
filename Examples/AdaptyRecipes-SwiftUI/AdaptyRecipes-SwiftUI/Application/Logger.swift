//
//  Logger.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import Foundation

class Logger {
    enum Level: String {
        case error
        case verbose
    }

    static func log(_ level: Level, _ message: String) {
        print("\(level.rawValue.uppercased()): \(message)")
    }
}
