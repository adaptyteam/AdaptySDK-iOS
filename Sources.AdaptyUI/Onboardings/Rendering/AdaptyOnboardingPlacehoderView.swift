//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/19/25.
//

#if canImport(UIKit)

import UIKit

package final class AdaptyOnboardingPlacehoderView: UIView {
    package override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private weak var activityIndicator: UIActivityIndicatorView?

    private func setup() {
        backgroundColor = .systemBackground

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        addSubview(activityIndicator)
        addConstraints([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        activityIndicator.color = UIColor.placeholderText
        activityIndicator.style = .large
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        self.activityIndicator = activityIndicator
    }
}

#endif
