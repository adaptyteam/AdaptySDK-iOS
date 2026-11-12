//
//  VC.DeckItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.08.2026.
//

import Foundation

extension VC {
    struct DeckItem: Sendable {
        let width: Length
        let height: Length
        let anchor: Point
        let position: Point
        /// Use anchor.x and position.x as physical coordinates. When mirrorInRTL is true
        /// and the layout direction is RTL, use 1 - anchor.x and 1 - position.x;
        /// otherwise keep both coordinates unchanged. Vertical coordinates are unchanged.
        let mirrorInRTL: Bool
        let content: ElementIndex
    }
}
