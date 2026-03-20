//
//  Schema.ConfigurationBuilder.Tasks.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.02.2026.
//

import Foundation

extension Schema.ConfigurationBuilder {
    enum Task {
        case leaveTemplate(String)
        case planElement(Schema.Element)
        case buildElement(Schema.Element)
    }

    typealias ResultStack = [VC.Element]
    typealias TasksStack = [Task]

    @inlinable
    func build_element(_ root: Schema.Element) throws(Schema.Error) -> VC.Element {
        var taskStack: TasksStack = [.planElement(root)]
        var resultStack = try startTasks(&taskStack)
        return try resultStack.popLastElement()
    }

    @inlinable
    func startTasks(
        _ taskStack: inout TasksStack
    ) throws(Schema.Error) -> ResultStack {
        var resultStack: ResultStack = []
        while let task = taskStack.popLast() {
            switch task {
            case let .planElement(value):
                try planElement(value, in: &taskStack)
            case let .leaveTemplate(id):
                templateIds.remove(id)
            case let .buildElement(value):
                if let result = try buildElement(value, &resultStack) {
                    resultStack.append(result)
                }
            }
        }
        return resultStack
    }
}

extension Schema.ConfigurationBuilder.ResultStack {
    @inlinable
    mutating func popLastElements(_ n: Int) throws(Schema.Error) -> Self {
//        guard n > 0 else { return []}
        guard count >= n else {
            throw .unsupportedElement("empty element tree")
        }
        let elements = suffix(n)
        removeLast(n)
        return Array(elements)
    }

    @inlinable
    mutating func popLastElement() throws(Schema.Error) -> Element {
        guard !isEmpty else {
            throw .unsupportedElement("empty element tree")
        }
        return removeLast()
    }

    @inlinable
    mutating func popLastElement(_ ifNeed: Bool) throws(Schema.Error) -> Element? {
        if ifNeed {
            try popLastElement()
        } else {
            nil
        }
    }
}
