//
//  VC.Animation.RotationParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension VC.Animation {
    struct RotationParameters: Sendable, Hashable {
        package let angle: Range<Double>
        package let anchor: VC.Point
    }
}

#if DEBUG
package extension VC.Animation.RotationParameters {
    static func create(
        angle: VC.Animation.Range<Double>,
        anchor: VC.Point = .center
    ) -> Self {
        .init(
            angle: angle,
            anchor: anchor
        )
    }
}
#endif
