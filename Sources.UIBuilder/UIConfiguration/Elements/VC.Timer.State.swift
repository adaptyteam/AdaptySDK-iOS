//
//  VC.Timer.State.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.Timer {
    enum State: Sendable, Hashable {
        case endedAt(Date)
        case duration(TimeInterval, start: StartBehavior)
    }
}
