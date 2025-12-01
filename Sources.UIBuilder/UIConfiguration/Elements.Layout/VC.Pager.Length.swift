//
//  VC.Pager.Length.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

package extension VC.Pager {
    enum Length: Sendable, Hashable {
        case fixed(VC.Unit)
        case parent(Double)
    }
}

extension VC.Pager.Length {
    static let `default` = Self.parent(1)
}
