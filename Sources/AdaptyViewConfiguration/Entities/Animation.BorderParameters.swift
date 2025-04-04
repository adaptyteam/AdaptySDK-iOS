//
//  Animation.BorderParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct BorderParameters: Sendable, Hashable {
        package let color: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>>?
        package let thickness: AdaptyViewConfiguration.Animation.Range<Double>?
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.BorderParameters {
    static func create(
        color: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>>? = nil,
        thickness: AdaptyViewConfiguration.Animation.Range<Double>? = nil
    ) -> Self {
        .init(
            color: color,
            thickness: thickness
        )
    }
}
#endif
