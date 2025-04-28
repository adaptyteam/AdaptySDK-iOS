//
//  HTTPSessionState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.08.2024
//

import Foundation

actor HTTPSessionState {
    private var taskStates = [Int: HTTPTaskState]()

    func set(taskState: HTTPTaskState, forTaskIdentifier taskIdentifier: Int) {
        taskStates[taskIdentifier] = taskState
    }

    func taskState(byTaskIdentifier taskIdentifier: Int) -> HTTPTaskState? {
        taskStates[taskIdentifier]
    }

    func removeTaskState(byTaskIdentifier taskIdentifier: Int) {
        taskStates.removeValue(forKey: taskIdentifier)
    }
}

actor HTTPTaskState {
    var taskIdentifier: Int?
    var metrics: URLSessionTaskMetrics?

    private weak var task: URLSessionTask?
    private var shouldCancel = false

    func start(_ task: URLSessionTask) {
        taskIdentifier = task.taskIdentifier
        if shouldCancel {
            task.cancel()
        } else {
            self.task = task
            task.resume()
        }
    }

    func cancel() {
        if let task = task {
            task.cancel()
        } else {
            shouldCancel = true
        }
    }

    func set(metrics: URLSessionTaskMetrics) {
        self.metrics = metrics
    }
}
