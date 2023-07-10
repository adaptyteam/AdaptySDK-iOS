//
//  Text.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct Text {
        static let defaultHorizontalAlign = HorizontalAlign.left
        static let empty = Text(
            bullet: nil,
            value: nil,
            font: nil,
            size: nil,
            fill: nil,
            horizontalAlign: defaultHorizontalAlign
        )

        public let bullet: Image?
        public let value: String?
        public let font: AdaptyUI.Font?
        public let size: Double?
        public let fill: AdaptyUI.Filling?
        public let horizontalAlign: AdaptyUI.HorizontalAlign
    }
}

extension AdaptyUI.Text {
    var asTextItems: AdaptyUI.TextItems {
        AdaptyUI.TextItems(items: [self], separator: .none)
    }
}
