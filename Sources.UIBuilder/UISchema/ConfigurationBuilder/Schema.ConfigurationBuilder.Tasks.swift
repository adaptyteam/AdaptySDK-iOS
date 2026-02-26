//
//  Schema.ConfigurationBuilder.Tasks.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.02.2026.
//

import Foundation

extension Schema.ConfigurationBuilder {
    enum Task {
        case planElement(Schema.Element)
        case leaveTemplate(String)
        case buildStack(Schema.Stack, VC.Element.Properties?)
        case buildBox(Schema.Box, VC.Element.Properties?)
        case buildButton(Schema.Button, VC.Element.Properties?)
        case buildRow(Schema.Row, VC.Element.Properties?)
        case buildColumn(Schema.Column, VC.Element.Properties?)
        case buildSection(Schema.Section, VC.Element.Properties?)
        case buildPager(Schema.Pager, VC.Element.Properties?)
    }

    @inlinable
    func build_element(_ root: Schema.Element) throws(Schema.Error) -> VC.Element {
        var taskStack: [Task] = [.planElement(root)]
        var elementStack = try startTasks(&taskStack)
        return try elementStack.popLastElement()
    }

    @inlinable
    func startTasks(
        _ taskStack: inout [Task]
    ) throws(Schema.Error) -> [VC.Element] {
        var elementStack: [VC.Element] = []
        while let work = taskStack.popLast() {
            let element: VC.Element
            switch work {
            case let .planElement(value):
                let result = try planElement(value, in: &taskStack)
                if let result {
                    elementStack.append(result)
                }
                continue
            case let .leaveTemplate(id):
                templateIds.remove(id)
                continue
            case let .buildButton(value, properties):
                element = try .button(buildButton(value, &elementStack), properties)
            case let .buildStack(value, properties):
                element = try .stack(buildStack(value, &elementStack), properties)
            case let .buildBox(value, properties):
                element = try .box(buildBox(value, &elementStack), properties)
            case let .buildRow(value, properties):
                element = try .row(buildRow(value, &elementStack), properties)
            case let .buildColumn(value, properties):
                element = try .column(buildColumn(value, &elementStack), properties)
            case let .buildSection(value, properties):
                element = try .section(buildSection(value, &elementStack), properties)
            case let .buildPager(value, properties):
                element = try .pager(buildPager(value, &elementStack), properties)
            }
            elementStack.append(element)
        }

        return elementStack
    }
}

extension [VC.Element] {
    @inlinable
    mutating func popLastElements(_ n: Int) throws(Schema.Error) -> Self {
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
