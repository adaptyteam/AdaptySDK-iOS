//
//  Asset.Font.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.Asset {
    public struct Font {
        public let name: String
        public let style: String
        public let defaultSize: Double?
        public let defaultColor: AdaptyUI.Color?
    }
}

extension AdaptyUI.Asset.Font: Decodable {
    enum CodingKeys: String, CodingKey {
        case name = "value"
        case style
        case defaultSize = "size"
        case defaultColor = "color"
    }
}
