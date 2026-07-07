//
//  TaskTimeoutsTests.swift
//  AdaptyTests
//
//  Created by Alexey Goncharov on 1/28/25.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

struct TaskTimeoutsTests {
    let duration: AdaptyDuration = .milliseconds(500)

    @Test func task() async {
        let start = AdaptyContinuousClock.now
        await #expect(throws: TimeoutError.self) {
            try await withThrowingTimeout(duration) {
                try await Task.sleep(duration: duration * 2)
            }
        }

        #expect(AdaptyContinuousClock.now - start < duration * 1.3)
    }

    @Test func zeroTimeoutThrowsTimeout() async {
        await #expect(throws: TimeoutError.self) {
            try await withThrowingTimeout(.zero) {
                try await Task.sleep(duration: .milliseconds(1))
            }
        }
    }

    @Test func completedOperationReturnsValue() async throws {
        let value = try await withThrowingTimeout(.seconds(1)) {
            42
        }

        #expect(value == 42)
    }

    @Test func taskWithoutCancellationHandler() async {
        let start = AdaptyContinuousClock.now
        await #expect(throws: TimeoutError.self) {
            try await withThrowingTimeout(duration) {
                let nestedTask = Task {
                    try await Task.sleep(duration: duration * 2)
                }

                try await nestedTask.value
            }
        }

        #expect(AdaptyContinuousClock.now - start > duration * 2)
    }

    @Test func taskWithCancellationHandler() async {
        let start = AdaptyContinuousClock.now
        await #expect(throws: TimeoutError.self) {
            try await withThrowingTimeout(duration) {
                let nestedTask = Task {
                    try await Task.sleep(duration: duration * 2)
                }

                // Add cleanup to ensure the task is cancelled if timeout occurs
                try await withTaskCancellationHandler {
                    try await nestedTask.value
                } onCancel: {
                    nestedTask.cancel()
                }
            }
        }

        #expect(AdaptyContinuousClock.now - start < duration * 1.3)
    }

    private actor Flag {
        private var _value = false

        var value: Bool {
            _value
        }

        func set() {
            _value = true
        }
    }
}

#endif
