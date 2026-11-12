//
//  Environment.Device.webUserAgent.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2024
//

import Foundation

#if canImport(WebKit)
import WebKit
#endif

private let log = Log.default

extension Environment.Device {
    @AdaptyActor
    private static var userAgentTask: Task<String?, Never>?

    @AdaptyActor
    static var webUserAgent: String? {
        get async {
            // A single task is shared by all callers, so a caller that enters
            // the actor while the first one is suspended doesn't create another web view.
            if let task = userAgentTask {
                return await task.value
            }

            let task = Task<String?, Never> { @MainActor in
                #if canImport(WebKit)
                // WKWebView is main-thread only: it is created, read and released on the main actor.
                WKWebView().value(forKey: "userAgent") as? String
                #else
                nil
                #endif
            }
            userAgentTask = task
            return await task.value
        }
    }
}
