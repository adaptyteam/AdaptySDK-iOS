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
        let mirrorInRTL: Bool
        let content: ElementIndex
        /// Use anchor.x and position.x as physical coordinates. When mirrorInRTL is true
        /// and the layout direction is RTL, use 1 - anchor.x and 1 - position.x;
        /// otherwise keep both coordinates unchanged. Vertical coordinates are unchanged.
        @available(*, deprecated, message: "Use anchor, position and mirrorInRTL instead.")
        let deprecatedHorizontalAlignment: HorizontalAlignment
        @available(*, deprecated, message: "Use anchor and position instead.")
        let deprecatedVerticalAlignment: VerticalAlignment
    }
}
