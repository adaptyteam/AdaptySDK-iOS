//
//  VC.RangeTextFormat.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension VC.RangeTextFormat {
    struct Item: Sendable, Hashable {
        let from: Double
        let value: VC.RichText
    }
}

extension VC.RangeTextFormat {
    func item(byValue: Double) -> VC.RichText {
        let index =
            if let index = items.firstIndex(where: { byValue > $0.from }) {
                index > 0 ? index - 1 : index
            } else {
                items.count - 1
            }
        guard items.indices.contains(index) else { return .empty }
        return items[index].value
    }
}
