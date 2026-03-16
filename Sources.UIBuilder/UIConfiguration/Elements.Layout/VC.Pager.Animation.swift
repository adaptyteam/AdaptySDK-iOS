//
//  VC.Pager.Animation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension VC.Pager {
    struct Animation: Sendable, Hashable {
        let startDelay: TimeInterval
        let pageTransition: VC.TransitionSlide
        let repeatTransition: VC.TransitionSlide?
        let afterInteractionDelay: TimeInterval
    }
}
