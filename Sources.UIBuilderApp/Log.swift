//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/23/25.
//

import AdaptyLogger
import AdaptyUIBuider
import Foundation

enum Log {
    static var stamp: String {
        AdaptyLogger.stamp
    }

    static func Category(name: String) -> AdaptyLogger.Category {
        AdaptyLogger.Category(
            subsystem: "io.adapty.ui",
            version: "UIBuilderApp:\(AdaptyUISchema.formatVersion)",
            name: name
        )
    }

    static let app = Category(name: "app")
}
