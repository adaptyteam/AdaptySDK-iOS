//
//  AdaptyGradientView.swift
//
//
//  Created by Alexey Goncharov on 2023-01-25.
//

import UIKit

class AdaptyGradientView: UIView {
    enum Position {
        case top
        case bottom
    }
    
    let position: Position
    
    init(position: Position) {
        self.position = position
        
        super.init(frame: .zero)

        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var gradientLayer: CAGradientLayer!

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isUserInteractionEnabled = false

        let gradientLayer = CAGradientLayer()
        
        switch position {
        case .top:
            gradientLayer.colors = [
                CGColor(gray: 17.0 / 255.0, alpha: 0.26),
                CGColor(gray: 17.0 / 255.0, alpha: 0.0),
            ]
        case .bottom:
            gradientLayer.colors = [
                CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
                CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4),
            ]
        }

        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = bounds

        layer.addSublayer(gradientLayer)

        self.gradientLayer = gradientLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
    }
}
