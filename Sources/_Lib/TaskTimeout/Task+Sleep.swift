//
//  Task+Sleep.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.09.2024
//

import Foundation

extension Task where Success == Never, Failure == Never {
    @inlinable
    static func sleep(duration value: TaskDuration) async throws {
        try await Task.sleep(nanoseconds: value.asNanoseconds)
    }

    @inlinable
    static func sleep(seconds: TimeInterval) async throws {
        try await Task.sleep(duration: TaskDuration(seconds))
    }
}
