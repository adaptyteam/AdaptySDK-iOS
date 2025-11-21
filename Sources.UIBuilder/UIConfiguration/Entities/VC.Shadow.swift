//
//  VC.Shadow.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2025
//

import Foundation

package extension VC {
    struct Shadow: Sendable, Hashable {
        static let `default` = Shadow(
            filling: .same(.solidColor(VC.Color.transparent)),
            blurRadius: 0.0,
            offset: VC.Offset.zero
        )
        package let filling: Mode<Filling>
        package let blurRadius: Double
        package let offset: Offset
    }
}

#if DEBUG
    package extension VC.Shadow {
        static func create(
            filling: VC.Mode<VC.Filling> = `default`.filling,
            blurRadius: Double = `default`.blurRadius,
            offset: VC.Offset = `default`.offset
        ) -> Self {
            .init(
                filling: filling,
                blurRadius: blurRadius,
                offset: offset
            )
        }
    }
#endif
