//
//  VC.RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension VC {
    struct RichText: Sendable {
        let items: [Item]
        let fallback: [Item]?
    }
}

extension VC.RichText {
    static let empty: Self = .init(items: [], fallback: nil)

    @inlinable
    var isEmpty: Bool {
        items.isEmpty
    }

    @inlinable
    var asString: String? {
        items.first.flatMap {
            if case let .text(value, attributes, _) = $0, attributes == nil { value } else { nil }
        }
    }
}
