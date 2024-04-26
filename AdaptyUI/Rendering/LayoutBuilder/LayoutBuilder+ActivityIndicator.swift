//
//  LayoutBuilder+ActivityIndicator.swift
//  
//
//  Created by Alexey Goncharov on 10.8.23..
//

import UIKit

extension LayoutBuilder {
    func layoutProgressView(_ view: AdaptyActivityIndicatorView, on superview: UIView) {
        superview.addSubview(view)
        superview.addConstraints([
            view.topAnchor.constraint(equalTo: superview.topAnchor),
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        ])
    }
}

