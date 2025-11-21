//
//  AdaptyUI+Log.swift
//
//
//  Created by Alexey Goncharov on 2023-01-25.
//

import Adapty
import AdaptyLogger

enum Log {
    static var stamp: String {
        AdaptyLogger.stamp
    }

    static func Category(name: String) -> AdaptyLogger.Category {
        AdaptyLogger.Category(
            subsystem: "io.adapty.ui",
            version: Adapty.SDKVersion,
            name: name
        )
    }

    static let ui = Category(name: "ui")
    static let onboardings = Category(name: "onboardings")
    static let cache = Category(name: "AdaptyMediaCache")
    static let prefetcher = Category(name: "ImageUrlPrefetcher")
}
