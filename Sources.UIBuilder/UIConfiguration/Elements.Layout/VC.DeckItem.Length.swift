//
//  VC.DeckItem.Length.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.08.2026.
//

import Foundation

extension VC.DeckItem {
    enum Length: Sendable {
        case fixed(VC.Unit)
        case parent(Double)
        case content
    }
}
