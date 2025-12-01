//
//  VC.GridItem.Length.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

package extension VC.GridItem {
    enum Length: Sendable, Hashable {
        case fixed(VC.Unit)
        case weight(Int)
    }
}
