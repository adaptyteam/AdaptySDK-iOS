//
//  Task+Sleep.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.09.2024
//

import Foundation

extension Task where Success == Never, Failure == Never {
    @inlinable
    static func sleep(duration value: AdaptyDuration) async throws {
        guard value > .zero else {
            try Task.checkCancellation()
            return
        }

        try await Task.sleep(nanoseconds: UInt64(value.nanoseconds))
    }
}
