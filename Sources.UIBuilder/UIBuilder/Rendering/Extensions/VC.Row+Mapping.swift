//
//  VC.Row+Mapping.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import Foundation

extension VC.Row {
    /// The `h_stack` that `draw_as_stack` renders instead of the row, or nil
    /// without it. Items keep their content and order; their lengths and
    /// alignments are dropped, as the stack has no place for them.
    var asStack: VC.Stack? {
        drawAsStack.map {
            .init(
                type: .horizontal,
                horizontalAlignment: $0.horizontalAlignment,
                verticalAlignment: $0.verticalAlignment,
                spacing: spacing,
                items: items.map { .element($0.content) }
            )
        }
    }
}

extension VC.Column {
    /// The `v_stack` that `draw_as_stack` renders instead of the column, or nil
    /// without it. Items keep their content and order; their lengths and
    /// alignments are dropped, as the stack has no place for them.
    var asStack: VC.Stack? {
        drawAsStack.map {
            .init(
                type: .vertical,
                horizontalAlignment: $0.horizontalAlignment,
                verticalAlignment: $0.verticalAlignment,
                spacing: spacing,
                items: items.map { .element($0.content) }
            )
        }
    }
}

#endif
