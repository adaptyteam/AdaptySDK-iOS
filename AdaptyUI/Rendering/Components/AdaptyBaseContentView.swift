//
//  AdaptyBaseContentView.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import Adapty
import UIKit

enum ContentLayout {
    case basic(multiplier: CGFloat)
    case transparent
    case flat
}

final class AdaptyBaseContentView: UIView {
    static let curveHeight: CGFloat = 36.0

    let layout: ContentLayout
    let shape: AdaptyUI.Decorator

    init(layout: ContentLayout, shape: AdaptyUI.Decorator) {
        self.layout = layout
        self.shape = shape

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Mask & Background

    private func updateMask() {
        switch shape.shapeType {
        case let .rectangle(radius):
            layer.applyRectangleMask(radius: radius)
        case .curveUp:
            layer.mask = CAShapeLayer.curveUpShapeLayer(in: bounds, curveHeight: Self.curveHeight)
        case .curveDown:
            layer.mask = CAShapeLayer.curveDownShapeLayer(in: bounds, curveHeight: Self.curveHeight)
        case .circle:
            break
        }

        layer.masksToBounds = true
    }

    private var gradientLayer: CAGradientLayer?

    private func updateBackground() {
        switch shape.background {
        case let .color(color):
            backgroundColor = color.uiColor
        case let .colorGradient(gradient):
            backgroundColor = .clear
            if let gradientLayer {
                gradientLayer.frame = bounds
            } else {
                let gradientLayer = CAGradientLayer.create(gradient)
                gradientLayer.frame = bounds
                layer.insertSublayer(gradientLayer, at: 0)
                self.gradientLayer = gradientLayer
            }
        default:
            break
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        updateMask()
        updateBackground()
    }

    private var contentInset: UIEdgeInsets = .zero
    private var contentTopConstraint: NSLayoutConstraint!
    private var contentBottomConstraint: NSLayoutConstraint!

    func updateSafeArea(_ insets: UIEdgeInsets) {
        switch layout {
        case .basic:
            contentBottomConstraint.constant = -(insets.bottom + contentInset.bottom)
        case .transparent, .flat:
            contentTopConstraint.constant = insets.top + contentInset.top
            contentBottomConstraint.constant = -(insets.bottom + contentInset.bottom)
        }
    }

    enum Layout {
        case topToBottom
        case bottomToTop
    }

    func layoutContent(_ view: UIView, inset: UIEdgeInsets, layout: Layout = .topToBottom) {
        contentInset = inset

        switch layout {
        case .topToBottom:
            contentTopConstraint =
                view.topAnchor.constraint(equalTo: topAnchor,
                                          constant: inset.top)
            contentBottomConstraint =
                view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
                                             constant: -inset.bottom)
        case .bottomToTop:
            contentTopConstraint =
                view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                          constant: inset.top)
            contentBottomConstraint =
                view.bottomAnchor.constraint(equalTo: bottomAnchor,
                                             constant: -inset.bottom)
        }

        addSubview(view)
        addConstraints([
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset.right),
            contentTopConstraint,
            contentBottomConstraint,
        ])
    }
}
