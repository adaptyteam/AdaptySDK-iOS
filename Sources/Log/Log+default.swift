//
//  Log+default.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

extension Log {
    static let `default` = Log.Category(
        subsystem: "io.adapty",
        version: Adapty.SDKVersion,
        name: "sdk"
    )

    static let events = Log.Category(name: "Events")
    static let storage = Log.Category(name: "Storage")
    static let network = Log.Category(name: "API")
}
