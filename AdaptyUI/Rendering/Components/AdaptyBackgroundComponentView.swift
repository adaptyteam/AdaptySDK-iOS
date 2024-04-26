//
//  AdaptyBackgroundComponentView.swift
//
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty
import UIKit

final class AdaptyBackgroundComponentView: UIImageView {
    private let background: AdaptyUI.Filling?

    init(background: AdaptyUI.Filling?) {
        self.background = background

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFill

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var gradientLayer: CAGradientLayer?

    private func setupView() {
        switch background {
        case .none:
            backgroundColor = .white
            image = nil
        case let .color(color):
            backgroundColor = color.uiColor
            image = nil
        case let .image(img):
            backgroundColor = nil
            setImage(img)
        case let .colorGradient(gradient):
            backgroundColor = nil
            image = nil

            let gradientLayer = CAGradientLayer.create(gradient)
            layer.insertSublayer(gradientLayer, at: 0)
            self.gradientLayer = gradientLayer
        }
    }
}
