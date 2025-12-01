//
//  VC.Pager.Animation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

package extension VC.Pager {
    struct Animation: Sendable, Hashable {
        package let startDelay: TimeInterval
        package let pageTransition: VC.TransitionSlide
        package let repeatTransition: VC.TransitionSlide?
        package let afterInteractionDelay: TimeInterval
    }
}

extension VC.Pager.Animation {
    static let `default` = (
        startDelay: 0.0,
        afterInteractionDelay: 3.0
    )
}

#if DEBUG
package extension VC.Pager.Animation {
    static func create(
        startDelay: TimeInterval = `default`.startDelay,
        pageTransition: VC.TransitionSlide = .create(),
        repeatTransition: VC.TransitionSlide? = nil,
        afterInteractionDelay: TimeInterval = `default`.afterInteractionDelay
    ) -> Self {
        .init(
            startDelay: startDelay,
            pageTransition: pageTransition,
            repeatTransition: repeatTransition,
            afterInteractionDelay: afterInteractionDelay
        )
    }
}
#endif
