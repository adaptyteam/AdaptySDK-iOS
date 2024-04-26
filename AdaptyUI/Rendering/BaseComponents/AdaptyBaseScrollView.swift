//
//  AdaptyBaseScrollView.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import UIKit

final class AdaptyBaseScrollView: UIScrollView {
    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        contentInsetAdjustmentBehavior = .never
        delegate = delegate
        alwaysBounceVertical = true
        delaysContentTouches = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
