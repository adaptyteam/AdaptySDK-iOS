//
//  ProductBadgeView.swift
//
//
//  Created by Alexey Goncharov on 16.8.23..
//

import Adapty
import UIKit

class ProductBadgeView: AdaptyShapeWithFillingView {
    let text: AdaptyUI.RichText
    let shape: AdaptyUI.Decorator?
    let tagConverter: AdaptyUI.CustomTagConverter?
        
    init(
        text: AdaptyUI.RichText,
        shape: AdaptyUI.Decorator?,
        tagConverter: AdaptyUI.CustomTagConverter?
    ) throws {
        self.text = text
        self.shape = shape
        self.tagConverter = tagConverter

        super.init(shape: shape)

        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() throws {
        let tagLabel = AdaptyInsetLabel()

        // TODO: inspect
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.attributedText = text.attributedString(
//            kern: 0.2,
            tagConverter: tagConverter
        )

        addSubview(tagLabel)
        addConstraints([
            tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
            tagLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2.0),
            tagLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2.0),
        ])
    }
}
