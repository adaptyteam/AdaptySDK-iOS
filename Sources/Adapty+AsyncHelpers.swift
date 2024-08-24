//
//  Adapty+AsyncHelpers.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

private let log = Log.default

extension Adapty {
    package static let underlayQueue = DispatchQueue(label: "AdaptySDK.Main")
    static var dispatchQueue: DispatchQueue?

    @inline(__always)
    static func async(
        _ completion: AdaptyErrorCompletion?,
        group: DispatchGroup? = nil,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        logName: String? = nil,
        logParams: EventParameters? = nil,
        function: StaticString = #function,
        execute work: @escaping (@escaping AdaptyErrorCompletion) -> Void
    ) {
        let stamp = Log.stamp
        if let logName {
            Adapty.logSystemEvent(AdaptySDKMethodRequestParameters(methodName: logName, callId: stamp, params: logParams))
        }
        log.verbose("Calling now: \(function) [\(stamp)].")
        underlayQueue.async(group: group, qos: qos, flags: flags) {
            work {
                callCompletion(logName: logName, function, stamp, completion, $0, logLevel: .error)
            }
        }
    }

    @inline(__always)
    static func async(
        _ completion: AdaptyErrorCompletion?,
        group: DispatchGroup? = nil,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        logName: String? = nil,
        logParams: EventParameters? = nil,
        function: StaticString = #function,
        execute work: @escaping (Adapty, @escaping AdaptyErrorCompletion) -> Void
    ) {
        let stamp = Log.stamp
        if let logName {
            Adapty.logSystemEvent(AdaptySDKMethodRequestParameters(methodName: logName, callId: stamp, params: logParams))
        }
        log.verbose("Calling now: \(function) [\(stamp)].")
        underlayQueue.async(group: group, qos: qos, flags: flags) {
            guard let manager = shared else {
                callCompletion(logName: logName, function, stamp, completion, AdaptyError.notActivated(), logLevel: .error)
                return
            }

            work(manager) {
                callCompletion(logName: logName, function, stamp, completion, $0)
            }
        }
    }

    @inline(__always)
    static func async<T>(
        _ completion: @escaping AdaptyResultCompletion<T>,
        group: DispatchGroup? = nil,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        logName: String? = nil,
        logParams: EventParameters? = nil,
        function: StaticString = #function,
        execute work: @escaping (Adapty, @escaping AdaptyResultCompletion<T>) -> Void
    ) {
        let stamp = Log.stamp
        if let logName {
            Adapty.logSystemEvent(AdaptySDKMethodRequestParameters(methodName: logName, callId: stamp, params: logParams))
        }
        log.verbose("Calling now: \(function) [\(stamp)].")
        underlayQueue.async(group: group, qos: qos, flags: flags) {
            guard let manager = shared else {
                callCompletion(logName: logName, function, stamp, completion, .failure(.notActivated()), logLevel: .error)
                return
            }

            work(manager) {
                callCompletion(logName: logName, function, stamp, completion, $0)
            }
        }
    }

    @inline(__always)
    private static func callCompletion(
        logName: String? = nil,
        _ function: StaticString,
        _ stamp: String,
        _ completion: AdaptyErrorCompletion?,
        _ error: AdaptyError? = nil,
        logLevel: Log.Level = .verbose
    ) {
        if let logName {
            Adapty.logSystemEvent(AdaptySDKMethodResponseParameters(methodName: logName, callId: stamp, error: error?.description))
        }

        if let error {
            log.message("Completed \(function) [\(stamp)] with error: \(error).", withLevel: logLevel)
        } else {
            log.message("Completed \(function) [\(stamp)] is successful.", withLevel: .verbose)
        }
        guard let completion else { return }
        (dispatchQueue ?? .main).async {
            completion(error)
        }
    }

    @inline(__always)
    private static func callCompletion<T>(logName: String? = nil, _ function: StaticString, _ stamp: String, _ completion: AdaptyResultCompletion<T>?, _ result: AdaptyResult<T>, logLevel: Log.Level = .verbose) {
        let error: AdaptyError? = if case let .failure(e) = result { e } else { nil }

        if let logName {
            Adapty.logSystemEvent(AdaptySDKMethodResponseParameters(methodName: logName, callId: stamp, error: error?.description))
        }

        if let error {
            log.message("Completed \(function) [\(stamp)]  with error: \(error).", withLevel: logLevel)
        } else {
            log.message("Completed \(function) [\(stamp)]  is successful.", withLevel: .verbose)
        }
        guard let completion else { return }
        (dispatchQueue ?? .main).async {
            completion(result)
        }
    }
}

extension DispatchQueue {
    static func syncInMainIfNeeded(_ closure: () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync(execute: closure)
            return
        }

        closure()
    }
}
