//
//  Adapty+AsyncHelper.swift
//  Adapty
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

extension Adapty {
    static let underlayQueue = DispatchQueue(label: "AdaptySDK.Main")
    static var dispatchQueue: DispatchQueue?

    @inline(__always)
    static func async(_ completion: AdaptyErrorCompletion?,
                      group: DispatchGroup? = nil,
                      qos: DispatchQoS = .unspecified,
                      flags: DispatchWorkItemFlags = [],
                      function: StaticString = #function,
                      execute work: @escaping (AdaptyErrorCompletion) -> Void) {
        let function = "\(function) [\(Log.stamp)]"
        Log.verbose("Calling now: \(function).")
        let event = Log.Profiling.start(method: "Public call", "%@", function)
        underlayQueue.async(group: group, qos: qos, flags: flags) {
            work({
                callCompletion(function, completion, $0, logLevel: .error)
                event.end($0 == nil ? "%@ Success" : "%@ Failed", function)
            })
        }
    }

    @inline(__always)
    static func async(_ completion: AdaptyErrorCompletion?,
                      group: DispatchGroup? = nil,
                      qos: DispatchQoS = .unspecified,
                      flags: DispatchWorkItemFlags = [],
                      function: StaticString = #function,
                      execute work: @escaping (Adapty, @escaping AdaptyErrorCompletion) -> Void) {
        let function = "\(function) [\(Log.stamp)]"
        Log.verbose("Calling now: \(function).")
        let event = Log.Profiling.start(method: "Public call", "%@", function)
        underlayQueue.async(group: group, qos: qos, flags: flags) {
            guard let manager = shared else {
                callCompletion(function, completion, AdaptyError.notActivated(), logLevel: .error)
                event.end("%@ Failed", function)
                return
            }

            work(manager, {
                callCompletion(function, completion, $0)
                event.end("%@ Success", function)
            })
        }
    }

    @inline(__always)
    static func async<T>(_ completion: @escaping AdaptyResultCompletion<T>,
                         group: DispatchGroup? = nil,
                         qos: DispatchQoS = .unspecified,
                         flags: DispatchWorkItemFlags = [],
                         function: StaticString = #function,
                         execute work: @escaping (Adapty, @escaping AdaptyResultCompletion<T>) -> Void) {
        let function = "\(function) [\(Log.stamp)]"
        Log.verbose("Calling now: \(function).")
        let event = Log.Profiling.start(method: "Public call", "%@", function)

        underlayQueue.async(group: group, qos: qos, flags: flags) {
            guard let manager = shared else {
                callCompletion(function, completion, .failure(.notActivated()), logLevel: .error)
                event.end("%@ Failed", function)
                return
            }

            work(manager, {
                callCompletion(function, completion, $0)
                event.end("%@ Success", function)
            })
        }
    }

    @inline(__always)
    private static func callCompletion(_ function: String, _ completion: AdaptyErrorCompletion?, _ error: AdaptyError? = nil,
                                       logLevel: AdaptyLogLevel = .verbose) {
        if let error = error {
            Log.message(logLevel, "Completed \(function) with error: \(error).")
        } else {
            Log.message(.verbose, "Completed \(function) is successful.")
        }
        guard let completion = completion else { return }
        (dispatchQueue ?? .main).async {
            completion(error)
        }
    }

    @inline(__always)
    private static func callCompletion<T>(_ function: String, _ completion: AdaptyResultCompletion<T>?, _ result: AdaptyResult<T>, logLevel: AdaptyLogLevel = .verbose) {
        if case let .failure(error) = result {
            Log.message(logLevel, "Completed \(function) with error: \(error).")
        } else {
            Log.message(.verbose, "Completed \(function) is successful.")
        }
        guard let completion = completion else { return }
        (dispatchQueue ?? .main).async {
            completion(result)
        }
    }
}
