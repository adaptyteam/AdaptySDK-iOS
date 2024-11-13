//
//  AdaptyPlugin+Log.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty

extension Log {
    static func Category(name: String) -> AdaptyLog.Category {
        AdaptyLog.Category(
            subsystem: "io.adapty",
            version: Adapty.SDKVersion,
            name: name
        )
    }

    static let plugin = Category(name: "plugin")
    static let wrapper = Category(name: "wrapper")
}

public extension AdaptyPlugin {
    static func logError(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.wrapper.error(message(), file: file, function: function, line: line)
    }
}
