//
//  Animation.BorderParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

package extension AdaptyUIConfiguration.Animation {
    struct BorderParameters: Sendable, Hashable {
        package let color: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.Filling>>?
        package let thickness: AdaptyUIConfiguration.Animation.Range<Double>?
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Animation.BorderParameters {
    static func create(
        color: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.Filling>>? = nil,
        thickness: AdaptyUIConfiguration.Animation.Range<Double>? = nil
    ) -> Self {
        .init(
            color: color,
            thickness: thickness
        )
    }
}
#endif
