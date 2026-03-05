//
//  VC.RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

package extension VC {
    struct RichText: Hashable {
        package let items: [Item]
        package let fallback: [Item]?
    }
}

package extension VC.RichText {
    static let empty: Self = .init(items: [], fallback: nil)
    var isEmpty: Bool {
        items.isEmpty
    }

    var asString: String? {
        items.first.flatMap {
            if case let .text(value, attributes, _) = $0, attributes == nil { value } else { nil }
        }
    }
}
