//
//  VC.Element.Properties.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension VC.Element {
    struct Properties: Sendable, Hashable {
        let decorator: VC.Decorator?
        let padding: VC.EdgeInsets
        let offset: VC.Offset

        let opacity: Double
        let onAppear: [VC.Animation]
    }
}

extension VC.Element.Properties {
    @inlinable
    var isEmpty: Bool {
        decorator == nil
            && padding.isZero
            && offset.isZero
            && opacity == 1.0
            && onAppear.isEmpty
    }
}
