//
//  VC.Stack.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension VC.Stack {
    enum Item: Sendable {
        case space(Int)
        case element(VC.ElementIndex)
    }
}
