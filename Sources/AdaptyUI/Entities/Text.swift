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
        package let value: Value
        package let maxRows: Int?
        package let overflowMode: Set<OverflowMode>

        package enum Value {
            case empty
            case text(RichText)
            case productDescription(RichText)
        }

        package enum OverflowMode: String {
            static let empty = Set<OverflowMode>()
            case truncate
            case scale
        }

        init(
            value: Value,
            maxRows: Int?,
            overflowMode: Set<OverflowMode>
        ) {
            self.value =
                switch value {
                case .empty: value
                case let .text(text),
                     let .productDescription(text):
                    text.isEmpty ? .empty : value
                }
            self.maxRows = maxRows
            self.overflowMode = overflowMode
        }
    }
}

extension AdaptyUI.Text {
    static let empty = AdaptyUI.Text(value: .empty, maxRows: nil, overflowMode: OverflowMode.empty)
}

extension AdaptyUI.Text.OverflowMode: Decodable {}
