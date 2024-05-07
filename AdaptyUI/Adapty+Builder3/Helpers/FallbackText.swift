//
//  FallbackText.swift
//
//
//  Created by Aleksey Goncharov on 4.4.24..
//

#if canImport(UIKit)

    import SwiftUI
    import UIKit

    @available(iOS 13.0, *)
    struct FallbackText: UIViewRepresentable {
        typealias UIViewType = UILabel

        var attributedText: NSAttributedString

        init(_ attributedText: NSAttributedString) {
            self.attributedText = attributedText
        }

        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()

            label.numberOfLines = 0
//            label.lineBreakMode = .byTruncatingTail
//            label.textAlignment = .justified
            label.allowsDefaultTighteningForTruncation = true

            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

            label.clipsToBounds = true

            return label
        }

        func updateUIView(_ uiView: UILabel, context: Context) {
            uiView.attributedText = attributedText
            uiView.preferredMaxLayoutWidth = 0.9 * UIScreen.main.bounds.width
        }
    }

#endif
