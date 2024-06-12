//
//  Text+ParagraphStyle.swift
//
//
//  Created by Aleksey Goncharov on 10.06.2024.
//

#if canImport(UIKit)

import Adapty
import UIKit

// TODO: remove
extension AdaptyUI.RichText {
    struct ParagraphStyle {
        let alignment: NSTextAlignment
        let lineSpacing: CGFloat
        let paragraphSpacing: CGFloat
        let firstLineHeadIndent: CGFloat
        let headIndent: CGFloat

        init(
            alignment: NSTextAlignment = .left,
            lineSpacing: CGFloat = 0.0,
            paragraphSpacing: CGFloat = 0.0,
            firstLineHeadIndent: CGFloat = 0.0,
            headIndent: CGFloat = 0.0
        ) {
            self.alignment = alignment
            self.lineSpacing = lineSpacing
            self.paragraphSpacing = paragraphSpacing
            self.firstLineHeadIndent = firstLineHeadIndent
            self.headIndent = headIndent
        }
    }
}

#endif
