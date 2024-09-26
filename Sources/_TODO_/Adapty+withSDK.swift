//
//  Adapty+withSDK.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2024
//

import Foundation

extension Adapty {
    //    static func withOptioanalSDK(
    //        methodName: MethodName? = nil,
    //        logParams: EventParameters? = nil,
    //        function: StaticString = #function,
    //        operation: @Sendable @escaping (Adapty?) async throws -> Void
    //    ) async throws {
    //        try await operation(nil)
    //    }

    static func withOptioanalSDK<T: Sendable>(
        methodName _: MethodName? = nil,
        logParams _: EventParameters? = nil,
        function _: StaticString = #function,
        operation: @AdaptyActor @Sendable @escaping (Adapty?) async throws -> T
    ) async throws -> T {
        try await operation(nil)
    }

    //    static func withActivatedSDK(
    //        methodName: MethodName? = nil,
    //        logParams: EventParameters? = nil,
    //        function: StaticString = #function,
    //        operation: @Sendable @escaping (Adapty) async throws -> Void
    //    ) async throws {
    //        try await operation(share)
    //    }

    static func withActivatedSDK<T: Sendable>(
        methodName _: MethodName? = nil,
        logParams _: EventParameters? = nil,
        function _: StaticString = #function,
        operation: @AdaptyActor @Sendable @escaping (Adapty) async throws -> T
    ) async throws -> T {
        try await operation(share)
    }
}
