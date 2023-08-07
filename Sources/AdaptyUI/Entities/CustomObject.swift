//
//  CustomObject.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.08.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct CustomObject {
        public let type: String
        public let properties: [String: AdaptyUI.LocalizedViewItem]
        public let orderedProperties: [(key: String, value: AdaptyUI.LocalizedViewItem)]
        init(type: String, orderedProperties: [(key: String, value: AdaptyUI.LocalizedViewItem)]) {
            self.type = type
            properties = [String: AdaptyUI.LocalizedViewItem](orderedProperties, uniquingKeysWith: { f, _ in f })
            self.orderedProperties = orderedProperties
        }
    }
}
