//
//  Border.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension AdaptyUI {
    struct Border {
        static let defaultThickness = 1.0
        package let filling: AdaptyUI.Filling
        package let thickness: Double
    }
}

#if DEBUG
    package extension AdaptyUI.Border {
        static func createColor(filling: AdaptyUI.Filling, thickness: Double) -> Self {
            .init(filling: filling, thickness: thickness)
        }
    }
#endif
