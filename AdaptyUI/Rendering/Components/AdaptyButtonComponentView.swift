//
//  AdaptyButtonComponentView.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.OldButton {
    func getStateShape(_ isSelected: Bool) -> AdaptyUI.Decorator? {
        if isSelected, let selected {
            return selected.shape
        } else {
            return normal?.shape
        }
    }

    func getStateTitle(_ isSelected: Bool) -> AdaptyUI.RichText? {
        if isSelected, let selected {
            return selected.title
        } else {
            return normal?.title
        }
    }
}

extension UIEdgeInsets {
    var toDicrectional: NSDirectionalEdgeInsets {
        .init(top: top, leading: left, bottom: bottom, trailing: right)
    }

    static let closeButtonDefaultMargin: UIEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
    static let footerButtonDefaultMargin: UIEdgeInsets = .init(top: 12, left: 0, bottom: 12, right: 0)
}

final class AdaptyButtonComponentView: UIButton {
    let component: AdaptyUI.OldButton
    let tagConverter: AdaptyUI.CustomTagConverter?
    let onTap: (AdaptyUI.ButtonAction?) -> Void

    private var gradientLayer: CAGradientLayer?
    private var contentView: UIView?
    private let contentViewMargins: UIEdgeInsets

    init(component: AdaptyUI.OldButton,
         tagConverter: AdaptyUI.CustomTagConverter?,
         contentView: UIView? = nil,
         contentViewMargins: UIEdgeInsets = .zero,
         addProgressView: Bool = false,
         onTap: @escaping (AdaptyUI.ButtonAction?) -> Void) {
        self.component = component
        self.tagConverter = tagConverter
        self.onTap = onTap
        self.contentViewMargins = contentViewMargins

        super.init(frame: .zero)

        isHidden = !component.visibility

        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true

        if let contentView {
            setupContentView(contentView, contentViewMargins)
        } else if let title = component.normal?.title?.attributedString(tagConverter: tagConverter) {
            setAttributedTitle(title, for: .normal)

            contentEdgeInsets = contentViewMargins
            titleLabel?.numberOfLines = 0

            if #available(iOS 15.0, *) {
                var configuration: UIButton.Configuration = .borderless()
                configuration = .plain()
                configuration.contentInsets = contentViewMargins.toDicrectional

                self.configuration = configuration
            } else {
                contentEdgeInsets = contentViewMargins
                titleEdgeInsets = contentViewMargins
            }
        }

        if addProgressView,
           case let .text(_, attributes) = component.normal?.title?.items.first(where: {
               guard case .text = $0 else { return false }
               return true
           }) {
            setAttributedTitle(NSAttributedString(string: ""), for: .disabled)
            setupActivityIndicator(color: attributes.uiColor ?? .white)
        }

        addTarget(self, action: #selector(buttonDidTouchUp), for: .touchUpInside)

        let shape = component.getStateShape(false)

        updateShapeMask(shape?.shapeType)
        updateShapeBackground(shape?.background)
        updateShapeBorder(shape?.border)
    }

    private func setupContentView(_ view: UIView, _ margins: UIEdgeInsets?) {
        if let contentView {
            contentView.removeFromSuperview()
        }

        view.isUserInteractionEnabled = false

        addSubview(view)
        addConstraints([
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margins?.left ?? 0.0),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(margins?.right ?? 0.0)),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(margins?.bottom ?? 0.0)),
            view.topAnchor.constraint(equalTo: topAnchor, constant: margins?.top ?? 0.0),
        ])

        contentView = view
    }

    private weak var progressView: UIActivityIndicatorView?

    private func setupActivityIndicator(color: UIColor) {
        let progressView = UIActivityIndicatorView(style: .medium)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.color = color
        progressView.isHidden = true
        addSubview(progressView)

        addConstraints([
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        self.progressView = progressView
    }

    func resetContent() {
        let title = component.getStateTitle(isSelected)
        updateContent(title)
    }

    func updateContent(_ text: AdaptyUI.RichText?) {
        contentView?.removeFromSuperview()
        contentView = nil

        setAttributedTitle(text?.attributedString(tagConverter: tagConverter), for: .normal)

        if #available(iOS 15.0, *) {
            var configuration: UIButton.Configuration = .borderless()
            configuration = .plain()
            configuration.contentInsets = contentViewMargins.toDicrectional

            self.configuration = configuration
        } else {
            contentEdgeInsets = contentViewMargins
            titleEdgeInsets = contentViewMargins
        }
    }

    func updateContent(_ view: UIView, margins: UIEdgeInsets?) {
        setupContentView(view, margins)
    }

    func performTransitionIn() {
        guard let transition = component.transitionIn.first(where: { $0.isFade }),
              case let .fade(animation) = transition else { return }

        performFadeAnimation(animation)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: {
                    self.alpha = self.isHighlighted ? 0.5 : 1
                },
                completion: nil)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let shape = component.getStateShape(isSelected)

        updateShapeMask(shape?.shapeType)
        updateShapeBackground(shape?.background)
        updateShapeBorder(shape?.border)
    }

    private func updateShapeBackground(_ filling: AdaptyUI.Filling?) {
        guard let filling = filling else {
            backgroundColor = .clear
            return
        }

        switch filling {
        case let .color(color):
            backgroundColor = color.uiColor
        case let .image(image):
            if currentBackgroundImage == nil {
                setBackgroundImage(image, for: .normal)
            }
            backgroundColor = .clear
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

    private func updateShapeBorder(_ border: AdaptyUI.Border?) {
        layer.borderColor = border?.filling.asColor?.uiColor.cgColor
        layer.borderWidth = border?.thickness ?? 0.0
    }

    private func updateShapeMask(_ type: AdaptyUI.ShapeType?) {
        layer.applyShapeMask(type)
    }

    @objc
    private func buttonDidTouchUp() {
        onTap(component.action)
    }

    func updateInProgress(_ inProgress: Bool) {
        guard let progressView = progressView else { return }

        progressView.isHidden = !inProgress
        isEnabled = !inProgress

        if inProgress {
            progressView.startAnimating()
        } else {
            progressView.stopAnimating()
        }
    }
}

extension AdaptyUI.Transition {
    var isFade: Bool {
        switch self {
        case .fade: return true
        default: return false
        }
    }
}

extension AdaptyUI.TransitionFade {
    var options: UIView.AnimationOptions {
        switch interpolator {
        case .easeIn: return [.curveEaseIn]
        case .easeOut: return [.curveEaseOut]
        case .easeInOut: return [.curveEaseInOut]
        default: return [.curveLinear]
        }
    }
}

extension UIView {
    func performFadeAnimation(_ animation: AdaptyUI.TransitionFade) {
        alpha = 0.0
        isHidden = false

        UIView.animate(withDuration: animation.duration,
                       delay: animation.startDelay,
                       options: animation.options) {
            self.alpha = 1.0
        }
    }
}
