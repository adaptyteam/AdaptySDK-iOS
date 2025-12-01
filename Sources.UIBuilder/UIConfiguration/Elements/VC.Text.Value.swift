//
//  VC.Text.Value.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.Text {
    enum Value: Sendable, Hashable {
        case text(VC.RichText)
        case productText(VC.LazyLocalizedProductText)
        case selectedProductText(VC.LazyLocalizedUnknownProductText)
    }
}
