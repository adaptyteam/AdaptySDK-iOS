//
//  VC.RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

package extension VC {
    struct RichText: Sendable, Hashable {
        package let items: [Item]
        package let fallback: [Item]?
    }
}

package extension VC.RichText {
    static let empty: Self = .init(items: [], fallback: nil)
    var isEmpty: Bool {
        items.isEmpty
    }
}
