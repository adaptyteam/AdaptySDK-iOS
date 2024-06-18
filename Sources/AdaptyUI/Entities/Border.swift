//
//  Border.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension AdaptyUI {
    struct Border {
        static let `default` = Border(
            filling: .color(AdaptyUI.Color.transparent),
            thickness: 1.0
        )

        package let filling: AdaptyUI.ColorFilling
        package let thickness: Double
    }
}

#if DEBUG
    package extension AdaptyUI.Border {
        static func create(
            filling: AdaptyUI.ColorFilling = `default`.filling,
            thickness: Double = `default`.thickness
        ) -> Self {
            .init(filling: filling, thickness: thickness)
        }
    }
#endif
