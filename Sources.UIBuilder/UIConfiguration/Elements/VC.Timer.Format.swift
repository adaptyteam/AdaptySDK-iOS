//
//  VC.Timer.Format.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 09.01.2026.
//

import Foundation

package extension VC.Timer {
    struct Format: Sendable, Hashable {
        package let items: [FormatItem]
        package let textAttributes: VC.RichText.Attributes?

        init(items: [FormatItem], textAttributes: VC.RichText.Attributes?) {
            self.items = items.sorted(by: { $0.from > $1.from }) // TODO: move on parsing
            self.textAttributes = textAttributes
        }
    }
}

package extension VC.Timer.Format {
    func item(byValue: TimeInterval) -> VC.RichText {
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
