//
//  AdaptyLogHandler+OSLog.swift
//
//
//  Created by Aleksei Valiano on 22.08.2024
//
//

import Foundation
import os.log

#if swift(<6.0)
    extension OSLog: @unchecked Sendable {}
#endif

extension Log {
    private static let logger = OSLog(subsystem: "io.adapty", category: "sdk")

    @Sendable
    static func defaultLogHandler(_ msg: AdaptyLogRecord) {
        os_log(msg.level.asOSLogType, log: logger, "%@\n%@", msg.value, msg.source.debugDescription)
    }
}

private extension AdaptyLogLevel {
    var asOSLogType: OSLogType {
        switch self {
        case .error:
            .fault
        case .warn:
            .error
        case .info:
            .default
        case .verbose:
            .info
        case .debug:
            .debug
        }
    }
}
