//
//  VC.Border.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    struct Border: Sendable, Hashable {
        package let filling: Mode<Filling>
        package let thickness: Double
    }
}

extension VC.Border {
    static let `default` = Self(
        filling: .same(.solidColor(VC.Color.transparent)),
        thickness: 1.0
    )
}

#if DEBUG
package extension VC.Border {
    static func create(
        filling: VC.Mode<VC.Filling> = `default`.filling,
        thickness: Double = `default`.thickness
    ) -> Self {
        .init(
            filling: filling,
            thickness: thickness
        )
    }
}
#endif
