//
//  Text.OverflowMode.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension AdaptyViewConfiguration.Text {
    package enum OverflowMode: String {
        case scale
        case unknown
    }
}

extension AdaptyViewConfiguration.Text.OverflowMode: Decodable {
    package init(from decoder: Decoder) throws {
        self =
            switch try decoder.singleValueContainer().decode(String.self) {
            case "scale":
                .scale
            default:
                .unknown
            }
    }
}
