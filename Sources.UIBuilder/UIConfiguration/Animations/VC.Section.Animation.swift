//
//  VC.Section.Animation.swift
//  Adapty
//
//  Created by Alex Goncharov on 10/04/2026.
//

import Foundation

extension VC.Section {
    struct Animation: Sendable, Hashable {
        let interpolator: VC.Animation.Interpolator
        let duration: TimeInterval
    }
}
