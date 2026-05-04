//
//  Task+sleep.swift
//  AdaptyUIBulder
//
//  Created by Aleksey Goncharov on 12.06.2024.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async throws {
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            try await Task.sleep(for: .seconds(seconds))
        } else {
            try await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
        }
    }
}
