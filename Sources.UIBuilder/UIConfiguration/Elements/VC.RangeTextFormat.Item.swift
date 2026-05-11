//
//  VC.RangeTextFormat.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension VC.RangeTextFormat {
    struct Item: Sendable {
        let from: Double
        let value: VC.RichText
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
