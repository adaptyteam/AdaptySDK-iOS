//
//  Adapty+Shared.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2024
//

import Foundation

private let log = Log.default

extension Adapty {
    public static var isActivated: Bool { shared != nil }

    private enum Shared {
        case activated(Adapty)
        case activating(Task<Adapty, Never>)
    }

    private static var shared: Shared?
    static func set(activatingSDK task: Task<Adapty, Never>) {
        if shared == nil { shared = .activating(task) }
    }

    static func set(shared sdk: Adapty) { shared = .activated(sdk) }

    @AdaptyActor
    package static var activatedSDK: Adapty {
        get async throws {
            switch shared {
            case let .some(.activated(sdk)):
                return sdk
            case let .some(.activating(task)):
                return await task.value
            default:
                throw AdaptyError.notActivated()
            }
        }
    }

    static var optionalSDK: Adapty? { // TODO: Deprecated
        if case let .some(.activated(sdk)) = shared {
            sdk
        } else {
            nil
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
        log.verbose("Calling now: \(function) [\(stamp)]  \(methodName): \(logParams?.description ?? "nil")")

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

    static func withoutSDK<T: Sendable>(
        methodName: MethodName,
        logParams: EventParameters? = nil,
        function: StaticString = #function,
        operation: @AdaptyActor @Sendable @escaping () async throws -> T
    ) async throws -> T {
        let stamp = Log.stamp

        Adapty.trackSystemEvent(AdaptySDKMethodRequestParameters(methodName: methodName, stamp: stamp, params: logParams))
        log.verbose("Calling now: \(function) [\(stamp)].  \(methodName): \(logParams?.description ?? "nil")")

        do {
            let result = try await operation()
            Adapty.trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: methodName, stamp: stamp))
            log.verbose("Completed \(function) [\(stamp)] is successful.")
            return result
        } catch {
            Adapty.trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: methodName, stamp: stamp, error: error.localizedDescription))
            log.error("Completed \(function) [\(stamp)] with error: \(error).")
            throw error
        }
    }
}
