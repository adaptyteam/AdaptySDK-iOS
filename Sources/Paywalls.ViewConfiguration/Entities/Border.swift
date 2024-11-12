//
//  Border.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension AdaptyUICore {
    struct Border: Sendable, Hashable {
        static let `default` = Border(
            filling: .same(.solidColor(AdaptyUICore.Color.transparent)),
            thickness: 1.0
        )

        package let filling: Mode<Filling>
        package let thickness: Double
    }
}

#if DEBUG
    package extension AdaptyUICore.Border {
        static func create(
            filling: AdaptyUICore.Mode<AdaptyUICore.Filling> = `default`.filling,
            thickness: Double = `default`.thickness
        ) -> Self {
            .init(filling: filling, thickness: thickness)
        }
    }
#endif
