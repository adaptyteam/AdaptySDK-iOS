//
//  VC.Element.Properties.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC.Element {
    struct Properties: Sendable, Hashable {
        package let decorator: VC.Decorator?
        package let padding: VC.EdgeInsets
        package let offset: VC.Offset

        package let opacity: Double
        package let onAppear: [VC.Animation]
    }
}

package extension VC.Element.Properties {
    var isEmpty: Bool {
        decorator == nil
            && padding.isZero
            && offset.isZero
            && opacity == 1.0
            && onAppear.isEmpty
    }
}
