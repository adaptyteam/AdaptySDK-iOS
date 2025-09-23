//
//  Border.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension AdaptyUIConfiguration {
    struct Border: Sendable, Hashable {
        static let `default` = Border(
            filling: .same(.solidColor(AdaptyUIConfiguration.Color.transparent)),
            thickness: 1.0
        )

        package let filling: Mode<Filling>
        package let thickness: Double
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Border {
    static func create(
        filling: AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.Filling> = `default`.filling,
        thickness: Double = `default`.thickness
    ) -> Self {
        .init(filling: filling, thickness: thickness)
    }
}
#endif
