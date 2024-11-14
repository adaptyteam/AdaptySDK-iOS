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
}

public struct PublicCategory {
    let wrapped: AdaptyLog.Category

    public init(subsystem: String, name: String) {
        wrapped = AdaptyLog.Category(subsystem: subsystem,
                                     version: Adapty.SDKVersion,
                                     name: name)
    }

    public func error(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        wrapped.error(message(), file: file, function: function, line: line)
    }
}
