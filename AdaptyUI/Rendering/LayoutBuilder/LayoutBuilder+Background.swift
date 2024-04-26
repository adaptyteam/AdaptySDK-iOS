//
//  File.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

extension LayoutBuilder {
    func layoutBackground(_ backgroundView: AdaptyBackgroundComponentView,
                          on view: UIView) {
        view.addSubview(backgroundView)
        view.addConstraints([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
        ])
    }
}
