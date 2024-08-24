//
//  Log+OSLog.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation
import os.log

#if swift(<6.0)
    extension OSLog: @unchecked Sendable {}
#endif

extension Log {
    @InternalActor
    private static var loggers = [Category: OSLog]()

    @InternalActor
    static func osLogWrite(_ record: Record) {
        let logger: OSLog

        if let value = Log.loggers[record.category] {
            logger = value
        } else {
            logger = OSLog(subsystem: record.category.subsystem, category: record.category.name)
            Log.loggers[record.category] = logger
        }
        os_log(record.level.asOSLogType, log: logger, "%@\nv%@, %@", record.message, record.category.version, record.source.description)
    }
}

private extension Log.Level {
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
