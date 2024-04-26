//
//  AdaptyUIElementView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

struct AdaptyUIElementView: View {
    var element: AdaptyUI.Element

    init(_ element: AdaptyUI.Element) {
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
        case let .stack(stack, properties):
            AdaptyUIStackView(stack, properties)
        case let .text(text, properties):
            AdaptyUIRichTextView(text)
                .applyingProperties(properties)
        case let .image(image, properties):
            AdaptyUIImageView(image)
                .applyingProperties(properties)
        case let .button(button, properties):
            button.applyingProperties(properties)
        case let .unknown(value, properties):
            AdaptyUIUnknownElementView(value: value)
                .applyingProperties(properties)
        }
    }
}
