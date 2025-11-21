//
//  Log+OSLog.swift
//  AdaptyLogger
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation
import os.log

extension AdaptyLogger {
    @InternalActor
    private static var loggers = [Category: OSLog]()

    @InternalActor
    static func osLogWrite(_ record: Record) {
        let logger: OSLog

        if let value = Self.loggers[record.category] {
            logger = value
        } else {
            logger = OSLog(subsystem: record.category.subsystem, category: record.category.name)
            Self.loggers[record.category] = logger
        }
        os_log(record.level.asOSLogType, log: logger, "%@\nv%@, %@", record.message, record.category.version, record.source.description)
    }
}

private extension AdaptyLogger.Level {
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
