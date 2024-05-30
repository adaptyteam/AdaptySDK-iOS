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
package struct AdaptyUIElementView: View {
    var element: AdaptyUI.Element
    var additionalPadding: EdgeInsets?

    package init(_ element: AdaptyUI.Element, additionalPadding: EdgeInsets? = nil) {
        self.element = element
        self.additionalPadding = additionalPadding
    }

    @ViewBuilder
    private func elementOrEmpty(_ content: AdaptyUI.Element?) -> some View {
        if let content {
            AdaptyUIElementView(content)
        } else {
            Color.clear
        }
    }

    package var body: some View {
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
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        case let .stack(stack, properties):
            AdaptyUIStackView(stack)
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        case let .text(text, properties):
            AdaptyUITextView(text)
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        case let .image(image, properties):
            AdaptyUIImageView(image)
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        case let .button(button, properties):
            AdaptyUIButtonView(button)
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        case let .unknown(value, properties):
            AdaptyUIUnknownElementView(value: value)
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        case let .row(row, properties):
            AdaptyUIRowView(row)
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        case let .column(column, properties):
            AdaptyUIUnknownElementView(value: "column")
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        case let .section(section, properties):
            AdaptyUISectionView(section)
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        case let .toggle(section, properties):
            AdaptyUIUnknownElementView(value: "toggle")
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        case let .timer(section, properties):
            AdaptyUIUnknownElementView(value: "timer")
                .paddingIfNeeded(additionalPadding)
                .applyingProperties(properties)
        }
    }
}

#endif
