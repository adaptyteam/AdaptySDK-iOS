//
//  VC.Timer.State.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension VC.Timer {
    enum State: Sendable, Hashable {
        case endedAt(VC.DateTime)
        case duration(TimeInterval, start: StartBehavior)
    }
}

