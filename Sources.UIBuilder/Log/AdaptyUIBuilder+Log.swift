//
//  AdaptyUIBuilder+Log.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/22/25.
//

import AdaptyLogger
import Foundation

enum Log {
    static var stamp: String {
        AdaptyLogger.stamp
    }

    static func Category(name: String) -> AdaptyLogger.Category {
        AdaptyLogger.Category(
            subsystem: "io.adapty.ui",
            version: "UIBuilder:\(AdaptyUISchema.formatVersion)",
            name: name
        )
    }

    static let ui = Category(name: "ui")
    static let cache = Category(name: "AdaptyMediaCache")
    static let prefetcher = Category(name: "ImageUrlPrefetcher")
}
