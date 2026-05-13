//
//  VC.RangeTextFormat.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension VC {
    struct RangeTextFormat: Sendable {
        let items: [Item]
        let textAttributes: VC.TextAttributes?

        init(items: [Item], textAttributes: VC.TextAttributes?) {
            self.items = items.sorted(by: { $0.from > $1.from }) // TODO: move on parsing
            self.textAttributes = textAttributes
        }
    }
}

extension VC.RangeTextFormat {
    func item(byValue: Double) -> VC.RichText {
        guard let item = items.first(where: { byValue >= $0.from }) else {
            return items.last?.value ?? .empty
        }
        return item.value
    }
}
