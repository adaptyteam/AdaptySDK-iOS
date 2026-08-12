//
//  TimeoutError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.09.2024
//
//

import Foundation

package struct TimeoutError: LocalizedError {
    package typealias Source = AdaptyError.Source

    package let errorDescription: String?
    package let source: Source

    init(
        _ duration: AdaptyDuration,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        errorDescription = "Task timed out before completion. Timeout: \(duration.asMilliseconds) milliseconds."
        source = Source(
            file: file,
            function: function,
            line: line
        )
    }
}
