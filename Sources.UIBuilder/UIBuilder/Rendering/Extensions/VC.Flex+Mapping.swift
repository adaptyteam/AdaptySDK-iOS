//
//  VC.Flex+Mapping.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import Foundation

extension VC.Flex.Direction: Equatable {}

extension VC.Flex.Direction {
    var opposite: VC.Flex.Direction {
        switch self {
        case .vertical: .horizontal
        case .horizontal: .vertical
        }
    }
}

extension VC.Flex {
    /// Row mode: main-axis size = `width`, spacing = `horizontalSpacing`.
    var asRow: VC.Row {
        .init(width: width, spacing: horizontalSpacing, items: items)
    }

    /// Column mode: main-axis size = `height`, spacing = `verticalSpacing`.
    var asColumn: VC.Column {
        .init(height: height, spacing: verticalSpacing, items: items)
    }
}

extension VC.FlexStack {
    func asStack(direction: VC.Flex.Direction) -> VC.Stack {
        .init(
            type: direction == .horizontal ? .horizontal : .vertical,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment,
            spacing: direction == .horizontal ? horizontalSpacing : verticalSpacing,
            items: items
        )
    }
}

#endif
