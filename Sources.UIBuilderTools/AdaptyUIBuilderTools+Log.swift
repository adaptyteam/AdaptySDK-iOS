//
//  AdaptyUIBuilderTools+Log.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2025.
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
}
