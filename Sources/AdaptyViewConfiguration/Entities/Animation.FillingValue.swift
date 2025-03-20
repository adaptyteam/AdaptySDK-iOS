//
//  Animation.FillingValue.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.03.2025.
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct FillingValue: Sendable, Hashable {
        package let interpolator: Interpolator
        package let start: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>
        package let end: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.FillingValue {
    static func create(
        start: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>,
        end: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator = .default
    ) -> Self {
        .init(
            interpolator: interpolator,
            start: start,
            end: end
        )
    }
}
#endif
