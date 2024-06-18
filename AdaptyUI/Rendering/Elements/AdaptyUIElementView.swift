//
//  AdaptyUIElementView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func paddingIfNeeded(_ insets: EdgeInsets?) -> some View {
        if let insets {
            padding(insets)
        } else {
            self
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Element {
    var properties: AdaptyUI.Element.Properties? {
        switch self {
        case .space:
            return nil
        case let .box(_, properties), let .stack(_, properties),
             let .text(_, properties), let .image(_, properties),
             let .button(_, properties), let .row(_, properties),
             let .column(_, properties), let .section(_, properties),
             let .toggle(_, properties), let .timer(_, properties),
             let .pager(_, properties), let .unknown(_, properties):
            return properties
        }
    }
}

@available(iOS 15.0, *)
package struct AdaptyUIElementView: View {
    private var element: AdaptyUI.Element
    private var additionalPadding: EdgeInsets?

    package init(_ element: AdaptyUI.Element, additionalPadding: EdgeInsets? = nil) {
        self.element = element
        self.additionalPadding = additionalPadding
    }

    package var body: some View {
        let properties = element.properties

        elementBody
            .paddingIfNeeded(additionalPadding)
            .applyingProperties(properties)
            .transitionIn(
                properties?.transitionIn,
                visibility: properties?.visibility ?? true
            )
    }

    @ViewBuilder
    private func elementOrEmpty(_ content: AdaptyUI.Element?) -> some View {
        if let content {
            AdaptyUIElementView(content)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private var elementBody: some View {
        switch element {
        case let .space(count):
            if count > 0 {
                ForEach(0 ..< count, id: \.self) { _ in
                    Spacer()
                }
            }
        case let .box(box, properties):
            elementOrEmpty(box.content)
                .fixedFrame(box: box)
                .rangedFrame(box: box)
        case let .stack(stack, properties):
            AdaptyUIStackView(stack)
        case let .text(text, properties):
            AdaptyUITextView(text)
        case let .image(image, properties):
            AdaptyUIImageView(image)
        case let .button(button, properties):
            AdaptyUIButtonView(button)
        case let .row(row, properties):
            AdaptyUIRowView(row)
        case let .column(column, properties):
            AdaptyUIColumnView(column)
        case let .section(section, properties):
            AdaptyUISectionView(section)
        case let .toggle(toggle, properties):
            AdaptyUIToggleView(toggle)
        case let .timer(timer, properties):
            AdaptyUITimerView(timer)
        case let .pager(pager, properties):
            AdaptyUIPagerView(pager)
        case let .unknown(value, properties):
            AdaptyUIUnknownElementView(value: value)
        }
    }
}

#endif
