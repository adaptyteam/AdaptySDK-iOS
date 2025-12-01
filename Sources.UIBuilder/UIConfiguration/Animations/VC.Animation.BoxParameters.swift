//
//  VC.Animation.BoxParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

package extension VC.Animation {
    struct BoxParameters: Sendable, Hashable {
        package let width: Range<VC.Unit>?
        package let height: Range<VC.Unit>?
    }
}

#if DEBUG
package extension VC.Animation.BoxParameters {
    static func create(
        width: VC.Animation.Range<VC.Unit>? = nil,
        height: VC.Animation.Range<VC.Unit>? = nil
    ) -> Self {
        .init(
            width: width,
            height: height
        )
    }
}
#endif
