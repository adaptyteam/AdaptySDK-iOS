//
//  VC.FooterBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct FooterBlock {
        let orderedItems: [(key: String, value: ViewItem)]
    }
}

extension AdaptyUI.ViewConfiguration.FooterBlock: Decodable {
    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewConfiguration.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderedItems = try container.toOrderedItems { _ in true }
    }
}
