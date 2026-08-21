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
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let content: ElementIndex
    }
}
