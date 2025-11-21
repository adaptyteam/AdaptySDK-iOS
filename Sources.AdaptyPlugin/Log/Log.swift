//
//  AdaptyPlugin+Log.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty
import AdaptyLogger

enum Log {
    static func Category(name: String) -> AdaptyLogger.Category {
        AdaptyLogger.Category(
            subsystem: "io.adapty",
            version: Adapty.SDKVersion,
            name: name
        )
    }

    static let plugin = Category(name: "plugin")
}
