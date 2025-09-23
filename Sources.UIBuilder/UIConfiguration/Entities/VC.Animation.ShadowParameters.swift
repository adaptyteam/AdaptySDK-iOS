//
//  Animation.ShadowParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

package extension AdaptyUIConfiguration.Animation {
    struct ShadowParameters: Sendable, Hashable {
        package let color: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.Filling>>?
        package let blurRadius: AdaptyUIConfiguration.Animation.Range<Double>?
        package let offset: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Offset>?
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Animation.ShadowParameters {
    static func create(
        color: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.Filling>>? = nil,
        blurRadius: AdaptyUIConfiguration.Animation.Range<Double>? = nil,
        offset: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Offset>? = nil
    ) -> Self {
        .init(
            color: color,
            blurRadius: blurRadius,
            offset: offset
        )
    }
}
#endif
