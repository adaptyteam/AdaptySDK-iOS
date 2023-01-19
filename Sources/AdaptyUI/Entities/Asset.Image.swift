//
//  Asset.Image.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.Asset {
    public struct Image {
        public let data: Data
    }
}

extension AdaptyUI.Asset.Image: Decodable {
    enum CodingKeys: String, CodingKey {
        case data = "value"
    }
}
