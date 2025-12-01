//
//  VC.Animation.ShadowParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

package extension VC.Animation {
    struct ShadowParameters: Sendable, Hashable {
        package let color: Range<VC.Mode<VC.Filling>>?
        package let blurRadius: Range<Double>?
        package let offset: Range<VC.Offset>?
    }
}

#if DEBUG
package extension VC.Animation.ShadowParameters {
    static func create(
        color: VC.Animation.Range<VC.Mode<VC.Filling>>? = nil,
        blurRadius: VC.Animation.Range<Double>? = nil,
        offset: VC.Animation.Range<VC.Offset>? = nil
    ) -> Self {
        .init(
            color: color,
            blurRadius: blurRadius,
            offset: offset
        )
    }
}
#endif
