//
//  VC.Pager.Animation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension VC.Pager {
    struct Animation: Sendable {
        let startDelay: TimeInterval
        let pageTransition: VC.Transition
        let repeatTransition: VC.Transition?
        let afterInteractionDelay: TimeInterval
    }
}
