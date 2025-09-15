//
//  Shadow.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2025
//

import Foundation

package extension AdaptyViewConfiguration {
    struct Shadow: Sendable, Hashable {
        static let `default` = Shadow(
            filling: .same(.solidColor(AdaptyViewConfiguration.Color.transparent)),
            blurRadius: 0.0,
            offset: AdaptyViewConfiguration.Offset.zero
        )
        package let filling: Mode<Filling>
        package let blurRadius: Double
        package let offset: Offset
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Shadow {
        static func create(
            filling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling> = `default`.filling,
            blurRadius: Double = `default`.blurRadius,
            offset: AdaptyViewConfiguration.Offset = `default`.offset
        ) -> Self {
            .init(
                filling: filling,
                blurRadius: blurRadius,
                offset: offset
            )
        }
    }
#endif
