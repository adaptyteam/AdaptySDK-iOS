//
//  Animation.ShadowParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct ShadowParameters: Sendable, Hashable {
        package let color: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>>?
        package let blurRadius: AdaptyViewConfiguration.Animation.Range<Double>?
        package let offset: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Offset>?
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.ShadowParameters {
    static func create(
        color: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>>? = nil,
        blurRadius: AdaptyViewConfiguration.Animation.Range<Double>? = nil,
        offset: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Offset>? = nil
    ) -> Self {
        .init(
            color: color,
            blurRadius: blurRadius,
            offset: offset
        )
    }
}
#endif
