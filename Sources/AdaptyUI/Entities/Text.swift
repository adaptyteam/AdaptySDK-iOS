//
//  Text.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Text {
        static let empty = AdaptyUI.Text(
            value: .text(.empty),
            maxRows: nil,
            overflowMode: .empty
        )

        package let value: Value
        package let maxRows: Int?
        package let overflowMode: Set<OverflowMode>

        package enum Value {
            case text(RichText)
            case productText(AdaptyUI.LazyLocalisedProductText)
            case selectedProductText(AdaptyUI.LazyLocalisedUnknownProductText)
        }
    }
}
