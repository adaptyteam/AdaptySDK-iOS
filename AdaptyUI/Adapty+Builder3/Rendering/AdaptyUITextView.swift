//
//  AdaptyUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

    import Adapty
    import SwiftUI

    @available(iOS 13.0, *)
    extension Text {
        func withAttributes(_ attributes: AdaptyUI.RichText.TextAttributes) -> Text {
            font(Font(attributes.font.uiFont(size: attributes.size)))
                .foregroundColor(attributes.txtColor.asColor?.swiftuiColor)
                .strikethrough(attributes.strike)
                .underline(attributes.underline)
//            .background(Color.yellow) as! Text
            // TODO: background
        }

        func withAttributes(_: AdaptyUI.RichText.ParagraphAttributes) -> Text {
            self
        }
    }

    @available(iOS 13.0, *)
    struct AdaptyUITextView: View {
        var text: AdaptyUI.Text

        init(_ text: AdaptyUI.Text) {
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

        @available(iOS 13.0, *)
        extension AdaptyUI.Color {
            static let testClear = AdaptyUI.Color(data: 0xFFFFFF00)
            static let testRed = AdaptyUI.Color(data: 0xFF0000FF)
            static let testGreen = AdaptyUI.Color(data: 0x00FF00FF)
            static let testBlue = AdaptyUI.Color(data: 0x0000FFFF)
        }

        @available(iOS 13.0, *)
        extension AdaptyUI.RichText.ParagraphAttributes {
            static var test: Self {
                .init(horizontalAlign: .left, firstIndent: 0.0, indent: 0.0, bulletSpace: nil, bullet: nil)
            }
        }

        @available(iOS 13.0, *)
        extension AdaptyUI.RichText.TextAttributes {
            static var testTitle: Self {
                .init(
                    font: .default,
                    size: 24.0,
                    txtColor: .color(.testRed),
                    imgTintColor: nil,
                    background: nil,
                    strike: false,
                    underline: false
                )
            }

            static var testBody: Self {
                .init(
                    font: .default,
                    size: 15.0,
                    txtColor: .color(.testRed),
                    imgTintColor: nil,
                    background: nil,
                    strike: false,
                    underline: false
                )
            }
        }

        @available(iOS 13.0, *)
        extension AdaptyUI.Text {
            init(_ items: [AdaptyUI.RichText.Item]) {
                self.init(
                    value: .text(.init(
                        items: items,
                        fallback: nil
                    )),
                    maxRows: nil,
                    overflowMode: Set<OverflowMode>()
                )
            }

            static var testBodyShort: Self {
                .init([
                    .text("Hello world!", .testBody),
                ])
            }

            static var testBodyShortAlignRight: Self {
                .init([
                    .paragraph(.init(horizontalAlign: .right, firstIndent: 0, indent: 0, bulletSpace: nil, bullet: nil)),
                    .text("Hello world!", .testBody),
                ])
            }

            static var testBodyLong: Self {
                .init([
                    .text("Hello world!", .testTitle),
                    .paragraph(.test),
                    .text("Hello world!", .testBody),
                ])
            }
        }

        @available(iOS 13.0, *)
        #Preview {
//    HStack {
            AdaptyUITextView(.testBodyLong)
                .background(Color.yellow)
//        Spacer()
//
//        AdaptyUI.RichText.testBodyLong
//            .background(Color.yellow)
//    }
        }
    #endif

#endif
