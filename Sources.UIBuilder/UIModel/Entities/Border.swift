//
//  Border.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    struct Border: Sendable, Hashable {
        static let `default` = Border(
            filling: .same(.solidColor(AdaptyViewConfiguration.Color.transparent)),
            thickness: 1.0
        )

        package let filling: Mode<Filling>
        package let thickness: Double
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Border {
    static func create(
        filling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling> = `default`.filling,
        thickness: Double = `default`.thickness
    ) -> Self {
        .init(filling: filling, thickness: thickness)
    }
}
#endif
