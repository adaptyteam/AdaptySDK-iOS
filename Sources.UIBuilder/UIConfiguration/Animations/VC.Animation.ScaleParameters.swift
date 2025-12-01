//
//  VC.Animation.ScaleParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension VC.Animation {
    struct ScaleParameters: Sendable, Hashable {
        package let scale: Range<VC.Point>
        package let anchor: VC.Point
    }
}

#if DEBUG
package extension VC.Animation.ScaleParameters {
    static func create(
        scale: VC.Animation.Range<VC.Point>,
        anchor: VC.Point = .center
    ) -> Self {
        .init(
            scale: scale,
            anchor: anchor
        )
    }
}
#endif
