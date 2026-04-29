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

    struct BuildResult {
        var elementIndices: [VC.ElementIndex]
        var poolElements: [VC.Element]
    }

    typealias TasksStack = [Task]

    @inlinable
    func startTasks(
        _ taskStack: inout TasksStack
    ) throws(Schema.Error) -> BuildResult {
        var elementIndices: [VC.ElementIndex] = []
        var poolElements: [VC.Element] = []
        while let task = taskStack.popLast() {
            switch task {
            case let .planElement(value):
                try planElement(value, in: &taskStack)
            case let .leaveTemplate(id):
                templateIds.remove(id)
            case let .buildElement(value):
                if let result = try buildElement(value, &elementIndices) {
                    elementIndices.append(poolElements.count)
                    poolElements.append(result)
                }
            }
        }
        return .init(
            elementIndices: elementIndices,
            poolElements: poolElements
        )
    }
}

extension [VC.ElementIndex] {
    @inlinable
    mutating func pop(_ n: Int) throws(Schema.Error) -> Self {
        precondition(n >= 0, "pop count must be non-negative, got \(n)")
        guard count >= n else {
            throw .unsupportedElement("empty element tree")
        }
        let elements = suffix(n)
        removeLast(n)
        return Array(elements)
    }

    @inlinable
    mutating func pop() throws(Schema.Error) -> Element {
        guard !isEmpty else {
            throw .unsupportedElement("empty element tree")
        }
        return removeLast()
    }

    @inlinable
    mutating func pop(_ ifNeed: Bool) throws(Schema.Error) -> Element? {
        if ifNeed {
            try pop()
        } else {
            nil
        }
    }
}
