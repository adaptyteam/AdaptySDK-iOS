//
//  AdaptyUI+Log.swift
//
//
//  Created by Alexey Goncharov on 2023-01-25.
//

import Adapty

extension Log {
    static func Category(name: String) -> AdaptyLog.Category {
        AdaptyLog.Category(subsystem: "io.adapty.ui", name: name)
    }

    static let ui = Category(name: "ui")
    static let onboardings = Category(name: "onboardings")
    static let cache = Category(name: "AdaptyMediaCache")
    static let prefetcher = Category(name: "ImageUrlPrefetcher")
}
