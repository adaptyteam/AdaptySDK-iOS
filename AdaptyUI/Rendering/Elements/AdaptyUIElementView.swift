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
             let .pager(_, properties), let .unknown(_, properties),
             let .video(_, properties):
            return properties
        }
    }
}

@available(iOS 15.0, *)
struct AdaptyUIElementWithoutPropertiesView: View {
    private var element: AdaptyUI.Element

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    init(
        _ element: AdaptyUI.Element
    ) {
        self.element = element
    }

    var body: some View {
        switch element {
        case let .space(count):
            if count > 0 {
                ForEach(0 ..< count, id: \.self) { _ in
                    Spacer()
                }
            }
        case let .box(box, _):
            elementOrEmpty(box.content)
                .fixedFrame(box: box)
                .rangedFrame(box: box)
        case let .stack(stack, _):
            AdaptyUIStackView(stack)
        case let .text(text, _):
            AdaptyUITextView(text)
        case let .image(image, _):
            AdaptyUIImageView(image)
        case let .video(video, _):
            AdaptyUIVideoView(video: video, colorScheme: colorScheme)
        case let .button(button, _):
            AdaptyUIButtonView(button)
        case let .row(row, _):
            AdaptyUIRowView(row)
        case let .column(column, _):
            AdaptyUIColumnView(column)
        case let .section(section, _):
            AdaptyUISectionView(section)
        case let .toggle(toggle, _):
            AdaptyUIToggleView(toggle)
        case let .timer(timer, _):
            AdaptyUITimerView(timer)
        case let .pager(pager, _):
            AdaptyUIPagerView(pager)
        case let .unknown(value, _):
            AdaptyUIUnknownElementView(value: value)
        }
    }

    @ViewBuilder
    private func elementOrEmpty(_ content: AdaptyUI.Element?) -> some View {
        if let content {
            AdaptyUIElementView(content)
        } else {
            Color.clear
                .frame(idealWidth: 0, idealHeight: 0)
        }
    }
}

@available(iOS 15.0, *)
package struct AdaptyUIElementView: View {
    private var element: AdaptyUI.Element
    private var additionalPadding: EdgeInsets?
    private var drawDecoratorBackground: Bool

    package init(
        _ element: AdaptyUI.Element,
        additionalPadding: EdgeInsets? = nil,
        drawDecoratorBackground: Bool = true
    ) {
        self.element = element
        self.additionalPadding = additionalPadding
        self.drawDecoratorBackground = drawDecoratorBackground
    }

    package var body: some View {
        let properties = element.properties

        AdaptyUIElementWithoutPropertiesView(element)
            .paddingIfNeeded(additionalPadding)
            .applyingProperties(properties, includeBackground: drawDecoratorBackground)
            .transitionIn(
                properties?.transitionIn,
                visibility: properties?.visibility ?? true
            )
            .modifier(DebugOverlayModifier())
    }
}

#endif
