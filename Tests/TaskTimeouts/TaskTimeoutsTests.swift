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
    let duration: TaskDuration = .milliseconds(500)

    @Test func testTask() async {
        let start = Date()
        await #expect(throws: TimeoutError.self) {
            try await withThrowingTimeout(duration) {
                try await Task.sleep(nanoseconds: 2 * duration.asNanoseconds)
            }
        }

        #expect(Date().timeIntervalSince(start) < 1.1 * duration.asTimeInterval)
    }

    @Test func testTaskWithoutCancellationHandler() async {
        let start = Date()
        await #expect(throws: TimeoutError.self) {
            try await withThrowingTimeout(duration) {
                let nestedTask = Task {
                    try await Task.sleep(nanoseconds: 2 * duration.asNanoseconds)
                }

                try await nestedTask.value
            }
        }

        #expect(Date().timeIntervalSince(start) > 2 * duration.asTimeInterval)
    }

    @Test func testTaskWithCancellationHandler() async {
        let start = Date()
        await #expect(throws: TimeoutError.self) {
            try await withThrowingTimeout(duration) {
                let nestedTask = Task {
                    try await Task.sleep(nanoseconds: 2 * duration.asNanoseconds)
                }

                // Add cleanup to ensure the task is cancelled if timeout occurs
                try await withTaskCancellationHandler {
                    try await nestedTask.value
                } onCancel: {
                    nestedTask.cancel()
                }
            }
        }

        #expect(Date().timeIntervalSince(start) < 1.1 * duration.asTimeInterval)
    }
}

#endif
