//
//  Adapty.Profiling.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

protocol ProfilingEvent {
    func end(_: StaticString, _: CVarArg...)
}

extension Log {
    struct ProfilingEventWrapper: ProfilingEvent {
        var event: ProfilingEvent?
        func end(_ format: StaticString, _ arguments: CVarArg...) {
            event?.end(format, arguments)
        }
    }

    enum Profiling {
        static func start(method: StaticString, _ format: StaticString, _ arguments: CVarArg...) -> ProfilingEventWrapper {
            #if canImport(os) && PROFILE
                return ProfilingEventWrapper(event: _ProfilingEvent.start(method: method, format, arguments))
            #else
                return ProfilingEventWrapper()
            #endif
        }
    }
}

#if canImport(os) && PROFILE
    import Foundation
    import os.signpost

    extension Log {
        struct _ProfilingEvent: ProfilingEvent {
            private static let handler = OSLog(subsystem: "AdaptySDK", category: "AdaptySDK")

            private let uniqueID: OSSignpostID
            private let method: StaticString

            private init(method: StaticString, uniqueID: OSSignpostID) {
                self.method = method
                self.uniqueID = uniqueID
            }

            static func start(method: StaticString, _ format: StaticString, _ arguments: CVarArg...) -> ProfilingEvent {
                let uniqueID = OSSignpostID(log: _ProfilingEvent.handler)
                os_signpost(
                    .begin,
                    log: _ProfilingEvent.handler,
                    name: method,
                    signpostID: uniqueID,
                    format,
                    arguments
                )
                return _ProfilingEvent(method: method, uniqueID: uniqueID)
            }

            func end(_ format: StaticString, _ arguments: CVarArg...) {
                os_signpost(
                    .end,
                    log: _ProfilingEvent.handler,
                    name: method,
                    signpostID: uniqueID,
                    format,
                    arguments
                )
            }
        }
    }
#endif
