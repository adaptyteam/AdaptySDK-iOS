//
//  AdaptyActivityIndicatorView.swift
//
//
//  Created by Alexey Goncharov on 2023-01-26.
//

import UIKit

class AdaptyActivityIndicatorView: UIView {
    private let indicatorColor: UIColor

    init(backgroundColor: UIColor, indicatorColor: UIColor) {
        self.indicatorColor = indicatorColor

        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var indicator: UIActivityIndicatorView!

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = indicatorColor

        addSubview(indicator)
        addConstraints([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        self.indicator = indicator
    }

    func show(animated: Bool) {
        guard animated else {
            alpha = 1.0
            isHidden = false
            return
        }

        alpha = 0.0
        isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
        
        indicator.startAnimating()
    }

    func hide(animated: Bool) {
        guard animated else {
            isHidden = true
            return
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.indicator.stopAnimating()
            self.isHidden = true
        })
    }
}
