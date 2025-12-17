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
