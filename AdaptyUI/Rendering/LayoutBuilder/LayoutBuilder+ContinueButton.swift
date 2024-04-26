//
//  File.swift
//
//
//  Created by Alexey Goncharov on 11.7.23..
//

import UIKit

extension LayoutBuilder {
    func layoutContinueButton(
        _ button: AdaptyButtonComponentView,
        placeholder: UIView,
        on superview: UIView
    ) {
        superview.addSubview(button)

        let centerY = button.centerYAnchor.constraint(equalTo: placeholder.centerYAnchor)
        centerY.priority = .defaultLow

        let bottom = button.bottomAnchor.constraint(lessThanOrEqualTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -16.0)
        bottom.priority = .defaultHigh

        superview.addConstraints([
            button.leadingAnchor.constraint(equalTo: placeholder.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: placeholder.trailingAnchor),
            button.heightAnchor.constraint(equalTo: placeholder.heightAnchor,
                                           multiplier: 1.0),
            centerY, bottom,
        ])
    }
}
