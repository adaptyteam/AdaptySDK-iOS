//
//  VC.Timer.StartBehavior.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.Timer {
    enum StartBehavior: Sendable, Hashable {
        case everyAppear
        case firstAppear
        case firstAppearPersisted
        case custom
    }
}

extension VC.Timer.StartBehavior {
    static let `default` = Self.firstAppear
}
