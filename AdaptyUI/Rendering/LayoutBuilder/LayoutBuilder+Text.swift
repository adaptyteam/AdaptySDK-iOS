//
//  LayoutBuilder+Text.swift
//
//
//  Created by Alexey Goncharov on 8.8.23..
//

import Adapty
import UIKit

extension LayoutBuilder {
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }

    func layoutTitleRows(_ text: AdaptyUI.RichText,
                         _ tagConverter: AdaptyUI.CustomTagConverter?,
                         in stackView: UIStackView) throws {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = text.attributedString(tagConverter: tagConverter)

        stackView.addArrangedSubview(label)
    }

    func layoutText(_ text: AdaptyUI.RichText,
                    _ tagConverter: AdaptyUI.CustomTagConverter?,
                    paragraph: AdaptyUI.RichText.ParagraphStyle? = nil,
                    numberOfLines: Int = 0,
                    in stackView: UIStackView) throws {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = numberOfLines
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.attributedText = text.attributedString(
            paragraph: paragraph ?? .init(),
            tagConverter: tagConverter
        )
        label.lineBreakMode = .byTruncatingTail

        stackView.addArrangedSubview(label)
    }
}
