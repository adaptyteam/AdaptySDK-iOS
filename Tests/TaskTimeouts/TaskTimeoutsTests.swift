//
//  TaskTimeoutsTests.swift
//  Adapty
//
//  Created by Alexey Goncharov on 1/28/25.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

struct TaskTimeoutsTests {
    @Test
    func testTask() async {
        let start = Date()
        
        do {
            try await withThrowingTimeout(.milliseconds(500)) {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
            
            #expect(false)
        } catch {
            print("error: \(error)")
            #expect(error is TimeoutError)
            #expect(Date().timeIntervalSince(start) < 0.75)
        }
    }
    
    @Test
    func testNestedTask() async {
        let start = Date()
        
        do {
            try await withThrowingTimeout(.milliseconds(500)) {
                let fetchTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                }

                return try await fetchTask.value
            }
            
            #expect(false)
        } catch {
            print("error: \(error)")
            #expect(error is TimeoutError)
            #expect(Date().timeIntervalSince(start) < 0.75)
        }
    }

    @Test
    func testNestedTaskFixed() async {
        let start = Date()
        
        do {
            try await withThrowingTimeout(.milliseconds(500)) {
                // Create the task with the current task's priority
                let fetchTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                }
                
                // Add cleanup to ensure the task is cancelled if timeout occurs
                try await withTaskCancellationHandler {
                    try await fetchTask.value
                } onCancel: {
                    fetchTask.cancel()
                }
            }
            
            #expect(false)
        } catch {
            print("error: \(error)")
            #expect(error is TimeoutError)
            #expect(Date().timeIntervalSince(start) < 0.75)
        }
    }
}

#endif
