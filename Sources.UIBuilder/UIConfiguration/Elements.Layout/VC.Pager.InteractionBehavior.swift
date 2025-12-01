//
//  VC.Pager.InteractionBehavior.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

package extension VC.Pager {
    enum InteractionBehavior: Sendable, Hashable {
        case none
        case cancelAnimation
        case pauseAnimation
    }
}

extension VC.Pager.InteractionBehavior {
    static let `default` = Self.pauseAnimation
}
