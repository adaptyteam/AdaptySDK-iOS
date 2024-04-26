//
//  AdaptyUI+Logger.swift
//
//
//  Created by Alexey Goncharov on 2023-01-25.
//

import Adapty
import Foundation

extension AdaptyUI {
    static func generateLogId() -> String {
        var result = ""
        let base62chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        for _ in 0 ..< 6 {
            result.append(base62chars[Int(arc4random_uniform(62))])
        }
        return result
    }

    public static func writeLog(level: AdaptyLogLevel,
                                message: String,
                                file: String = #fileID,
                                function: String = #function,
                                line: UInt = #line) {
        Adapty.writeLog(level: level,
                        message: "[UI \(AdaptyUI.SDKVersion)] \(message)",
                        file: file,
                        function: function,
                        line: line)
    }
}
