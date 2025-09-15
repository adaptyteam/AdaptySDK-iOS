//
//  Shadow.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2025
//

import Foundation

package extension AdaptyUIConfiguration {
    struct Shadow: Sendable, Hashable {
        static let `default` = Shadow(
            filling: .same(.solidColor(AdaptyUIConfiguration.Color.transparent)),
            blurRadius: 0.0,
            offset: AdaptyUIConfiguration.Offset.zero
        )
        package let filling: Mode<Filling>
        package let blurRadius: Double
        package let offset: Offset
    }
}

#if DEBUG
    package extension AdaptyUIConfiguration.Shadow {
        static func create(
            filling: AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.Filling> = `default`.filling,
            blurRadius: Double = `default`.blurRadius,
            offset: AdaptyUIConfiguration.Offset = `default`.offset
        ) -> Self {
            .init(
                filling: filling,
                blurRadius: blurRadius,
                offset: offset
            )
        }
    }
#endif
