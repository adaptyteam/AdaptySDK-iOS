//
//  LayoutBuilder+Gradient.swift
//  
//
//  Created by Alexey Goncharov on 14.8.23..
//

import UIKit

extension LayoutBuilder {
    func layoutTopGradientView(_ gradientView: UIView, on view: UIView) {
        view.addSubview(gradientView)
        view.addConstraints([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.0),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func layoutBottomGradientView(_ gradientView: UIView, on view: UIView) {
        view.addSubview(gradientView)
        view.addConstraints([
            gradientView.heightAnchor.constraint(equalToConstant: 100.0),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
