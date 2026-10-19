//
//  VC.Element+AvailableHeight.swift
//  AdaptyUIBuilder
//

import Foundation

extension VC.Element {
    /// The elements this one renders, its backgrounds and overlays included.
    var renderedElements: [VC.ElementIndex] {
        let own: [VC.ElementIndex] =
            switch self {
            case let .stack(stack, _): stack.items.elements
            case let .flexStack(flexStack, _): flexStack.items.elements
            case let .box(box, _): box.content.map { [$0] } ?? []
            case let .deck(deck, _): deck.items.map(\.content)
            case let .row(row, _): row.items.map(\.content)
            case let .column(column, _): column.items.map(\.content)
            case let .flex(flex, _): flex.items.map(\.content)
            case let .section(section, _): section.content
            case let .switch(`switch`, _): `switch`.cases.map(\.content) + [`switch`.default]
            case let .button(button, _): [button.content] + (button.legacySelectedContent.map { [$0] } ?? [])
            case let .pager(pager, _): pager.content
            case .text, .textField, .slider, .image, .video, .toggle, .timer, .dateTimePicker,
                 .wheelItemsPicker, .wheelRangePicker, .linearProgress, .radialProgress, .textProgress,
                 .custom, .screenHolder, .unknown:
                []
            }
        let decorations = (properties?.background ?? []) + (properties?.overlay ?? [])
        return own + decorations.map(\.content)
    }

    /// A `flex`, `flex_stack` or `switch` with a condition on `available_height`.
    var picksLayoutFromHeight: Bool {
        let conditions: [VC.Condition] =
            switch self {
            case let .flexStack(flexStack, _): flexStack.condition
            case let .flex(flex, _): flex.condition
            case let .switch(`switch`, _): `switch`.cases.flatMap(\.condition)
            default: []
            }
        return conditions.contains {
            if case .availableHeight = $0 { true } else { false }
        }
    }
}

extension [VC.Element] {
    /// Whether the element at `index`, or anything it renders, picks its layout
    /// from `available_height`.
    func picksLayoutFromHeight(_ index: VC.ElementIndex) -> Bool {
        var visited = Set<VC.ElementIndex>()
        var pending = [index]
        while let next = pending.popLast() {
            guard visited.insert(next).inserted, indices.contains(next) else { continue }
            if self[next].picksLayoutFromHeight { return true }
            pending += self[next].renderedElements
        }
        return false
    }
}

private extension [VC.Stack.Item] {
    var elements: [VC.ElementIndex] {
        compactMap { if case let .element(index) = $0 { index } else { nil } }
    }
}
