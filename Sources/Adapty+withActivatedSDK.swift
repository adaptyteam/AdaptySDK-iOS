//
//  Adapty+withActivatedSDK.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2024
//

import Foundation

private let log = Log.default

extension Adapty {
    private static var shared: Adapty?

    static func set(shared: Adapty) {
        self.shared = shared
    }

    static func withOptioanalSDK<T: Sendable>(
        methodName: MethodName,
        logParams: EventParameters? = nil,
        function: StaticString = #function,
        operation: @AdaptyActor @Sendable @escaping (Adapty?) async throws -> T
    ) async throws -> T {
        let stamp = Log.stamp

        Adapty.trackSystemEvent(AdaptySDKMethodRequestParameters(methodName: methodName, stamp: stamp, params: logParams))
        log.verbose("Calling now: \(function) [\(stamp)].  event: \(methodName) logParams: \(logParams?.description ?? "nil")")

        do {
            let result = try await operation(Adapty.shared)
            Adapty.trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: methodName, stamp: stamp))
            log.verbose("Completed \(function) [\(stamp)] is successful.")
            return result
        } catch {
            Adapty.trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: methodName, stamp: stamp, error: error.localizedDescription))
            log.error("Completed \(function) [\(stamp)] with error: \(error).")
            throw error
        }
    }

    static func withActivatedSDK<T: Sendable>(
        methodName: MethodName,
        logParams: EventParameters? = nil,
        function: StaticString = #function,
        operation: @AdaptyActor @Sendable @escaping (Adapty) async throws -> T
    ) async throws -> T {
        let stamp = Log.stamp

        Adapty.trackSystemEvent(AdaptySDKMethodRequestParameters(methodName: methodName, stamp: stamp, params: logParams))
        log.verbose("Calling now: \(function) [\(stamp)]  methodName: \(methodName) logParams: \(logParams?.description ?? "nil")")

        do {
            let result = try await operation(Adapty.activatedSDK)
            Adapty.trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: methodName, stamp: stamp))
            log.verbose("Completed \(function) [\(stamp)] is successful.")
            return result
        } catch {
            Adapty.trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: methodName, stamp: stamp, error: String(describing: error)))
            log.error("Completed \(function) [\(stamp)] with error: \(error).")
            throw error
        }
    }

    static var activatedSDK: Adapty {
        get throws {
            guard let share = Adapty.shared else {
                throw AdaptyError.notActivated()
            }
            return share
        }
    }
}
