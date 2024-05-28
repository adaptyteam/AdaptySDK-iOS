//
//  Testable+Text.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit) && DEBUG

import Adapty
import Foundation

@available(iOS 15.0, *)
extension AdaptyUI.RichText.ParagraphAttributes {
    static var test: Self {
        .create(
            horizontalAlign: .left,
            firstIndent: 0.0,
            indent: 0.0,
            bulletSpace: nil,
            bullet: nil
        )
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.RichText.TextAttributes {
    static var testTitle: Self {
        .create(
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
        .create(
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

@available(iOS 15.0, *)
extension AdaptyUI.RichText {
    static var testBodyShort: Self {
        .create(items: [.text("Hello world!", .testBody)])
    }

    static var testBodyShortAlignRight: Self {
        .create(items: [
            .paragraph(.create(horizontalAlign: .right, firstIndent: 0, indent: 0, bulletSpace: nil, bullet: nil)),
            .text("Hello world!", .testBody),
        ])
    }

    static var testBodyLong: Self {
        .create(items: [
            .text("Hello world!", .testTitle),
            .paragraph(.test),
            .text("Hello world!", .testBody),
            .paragraph(.test),
            .tag("TEST_TAG", .testBody),
        ])
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Text {
    static var testBodyShort: Self {
        .create(
            value: .text(.testBodyShort),
            maxRows: nil,
            overflowMode: [.scale]
        )
    }

    static var testBodyShortAlignRight: Self {
        .create(
            value: .text(.testBodyShortAlignRight),
            maxRows: nil,
            overflowMode: [.scale]
        )
    }

    static var testBodyLong: Self {
        .create(
            value: .text(.testBodyLong),
            maxRows: nil,
            overflowMode: [.scale]
        )
    }
}

#endif
