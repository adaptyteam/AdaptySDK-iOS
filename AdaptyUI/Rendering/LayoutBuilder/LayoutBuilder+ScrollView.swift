//
//  LayoutBuilder+ScrollView.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import UIKit

extension LayoutBuilder {
    func layoutScrollView(_ scrollView: AdaptyBaseScrollView, on superview: UIView) {
        superview.addSubview(scrollView)
        superview.addConstraints([
            scrollView.topAnchor.constraint(equalTo: superview.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        ])
    }
}
