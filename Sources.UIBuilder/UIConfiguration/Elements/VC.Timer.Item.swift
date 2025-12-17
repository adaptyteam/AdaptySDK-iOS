//
//  VC.Timer.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.Timer {
    struct Item: Sendable, Hashable {
        package let from: TimeInterval
        package let value: VC.RichText
    }
}
