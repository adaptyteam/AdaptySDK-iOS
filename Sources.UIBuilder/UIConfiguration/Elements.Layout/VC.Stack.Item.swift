//
//  VC.Stack.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.Stack {
    enum Item: Sendable, Hashable {
        case space(Int)
        case element(VC.Element)
    }
}
