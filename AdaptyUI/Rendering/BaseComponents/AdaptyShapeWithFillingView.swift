//
//  AdaptyShapeWithFillingView.swift
//
//
//  Created by Alexey Goncharov on 29.8.23..
//

import Adapty
import UIKit

class AdaptyShapeWithFillingView: UIView {
    private var gradientLayer: CAGradientLayer?
    private var imageView: UIImageView?

    private let shape: AdaptyUI.Decorator?

    init(shape: AdaptyUI.Decorator?) {
        self.shape = shape

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        applyFilling(shape?.background)
        layer.applyShapeMask(shape?.shapeType)
    }

    private func applyFilling(_ filling: AdaptyUI.Filling?) {
        guard let filling = filling else {
            backgroundColor = .clear
            return
        }

        switch filling {
        case let .color(color):
            backgroundColor = color.uiColor
        case let .image(image):
            backgroundColor = .clear
            if let imageView = imageView {
                imageView.setImage(image)
            } else {
                let imageView = UIImageView()
                imageView.setImage(image)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                addConstraints([
                    imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    imageView.topAnchor.constraint(equalTo: topAnchor),
                    imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])
            }
        case let .colorGradient(gradient):
            if let gradientLayer = gradientLayer {
                gradientLayer.frame = bounds
            } else {
                let gradientLayer = CAGradientLayer.create(gradient)
                gradientLayer.frame = bounds
                layer.insertSublayer(gradientLayer, at: 0)
                self.gradientLayer = gradientLayer
            }
            backgroundColor = .clear
        }
    }
}
