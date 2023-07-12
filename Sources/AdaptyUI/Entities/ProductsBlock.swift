//
//  ProductsBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public struct ProductsBlock {
        public let type: ProductsBlockType
        public let mainProductIndex: Int
        public lazy var items = { Dictionary(uniqueKeysWithValues: orderedItems) }()
        public let orderedItems: [(key: String, value: AdaptyUI.LocalizedViewItem)]
    }

    public enum ProductsBlockType: String {
        case single
        case vertical
        case horizontal
    }
}
