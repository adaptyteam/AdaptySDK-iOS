//
//  ProductsBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public struct ProductsBlock {
        let type: ProductsBlockType
        let mainProductIndex: Int
        let items: [String: AdaptyUI.LocalizedViewItem]
    }

    public enum ProductsBlockType: String {
        case single
        case vertical
        case horizontal
    }
}
