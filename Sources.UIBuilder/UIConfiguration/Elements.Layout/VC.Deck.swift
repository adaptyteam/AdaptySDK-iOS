//
//  VC.Deck.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.08.2026.
//

import Foundation

extension VC {
    struct Deck: Sendable {
        let width: AutoSizeMode
        let height: AutoSizeMode
        let items: [DeckItem]
    }
}
