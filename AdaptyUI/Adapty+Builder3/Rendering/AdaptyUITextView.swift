//
//  AdaptyUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

extension Text {
    func withAttributes(_ attributes: AdaptyUI.RichText.TextAttributes) -> Text {
        font(Font(attributes.font.uiFont(size: attributes.size)))
            .foregroundColor(attributes.color.asColor?.swiftuiColor)
            .strikethrough(attributes.strike)
            .underline(attributes.underline)
//            .background(Color.yellow) as! Text
        // TODO: background
    }

    func withAttributes(_ attributes: AdaptyUI.RichText.ParagraphAttributes) -> Text {
        self
    }
}

struct AdaptyUIRichTextView: View {
    var text: AdaptyUI.RichText

    init(_ text: AdaptyUI.RichText) {
        self.text = text
    }

    // TODO: add tagConverter

    @available(iOS 15, *)
    private var attributedString: AttributedString {
        AttributedString(text.attributedString(tagConverter: nil))
    }

    private var nsAttributedString: NSAttributedString {
        text.attributedString(tagConverter: nil)
    }

    private var plainString: String {
        text.attributedString(tagConverter: nil).string
    }

    var body: some View {
        if false, #available(iOS 15, *) {
            Text(attributedString)
        } else {
            FallbackText(nsAttributedString)
                .fixedSize(horizontal: true, vertical: true)
                .background(Color.green)
//            items.reduce(Text("")) { partialResult, item in
//                switch item {
//                case let .text(value, attr):
//                    return partialResult + Text(value).withAttributes(attr)
//                case let .tag(value, attr):
//                    // TODO: replace tags
//                    return partialResult + Text(value).withAttributes(attr)
//                case let .paragraph(attr):
//                    return partialResult.withAttributes(attr) + Text("\n")
//                case let .image(imageData, attributes):
//                    // TODO: implement
//                    return partialResult // + Text(Image("123"))
//                }
//            }
        }
    }
}

// TODO: remove before release

#if DEBUG
    @testable import Adapty

    extension AdaptyUI.Color {
        static let testClear = AdaptyUI.Color(data: 0xFFFFFF00)
        static let testRed = AdaptyUI.Color(data: 0xFF0000FF)
        static let testGreen = AdaptyUI.Color(data: 0x00FF00FF)
        static let testBlue = AdaptyUI.Color(data: 0x0000FFFF)
    }

    extension AdaptyUI.RichText.ParagraphAttributes {
        static var test: Self {
            .init(horizontalAlign: .left, firstIndent: 0.0, indent: 0.0, bulletSpace: nil, bullet: nil)
        }
    }

    extension AdaptyUI.RichText.TextAttributes {
        static var testTitle: Self {
            .init(font: .default, size: 24.0, color: .color(.testRed), background: nil, strike: false, underline: false)
        }

        static var testBody: Self {
            .init(font: .default, size: 15.0, color: .color(.testRed), background: nil, strike: false, underline: false)
        }
    }

    extension AdaptyUI.RichText {
        static var testBodyShort: Self {
            .init(items: [.text("Hello world!", .testBody)], fallback: nil)
        }
        
        static var testBodyShortAlignRight: Self {
            .init(items: [
                .paragraph(.init(horizontalAlign: .right, firstIndent: 0, indent: 0, bulletSpace: nil, bullet: nil)),
                .text("Hello world!", .testBody)
            ], fallback: nil)
        }

        static var testBodyLong: Self {
            .init(items: [
                .text("Hello world!", .testTitle),
                .paragraph(.test),
                .text("Hello world!", .testBody),
            ], fallback: nil)
        }
    }

    #Preview {
//    HStack {
        AdaptyUIRichTextView(.testBodyLong)
            .background(Color.yellow)
//        Spacer()
//
//        AdaptyUI.RichText.testBodyLong
//            .background(Color.yellow)
//    }
    }
#endif
