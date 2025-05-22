//
//  Text.OverflowMode.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

package extension AdaptyViewConfiguration.Text {
    enum OverflowMode: String {
        case scale
        case unknown
    }
}

extension AdaptyViewConfiguration.Text.OverflowMode: Codable {
    package init(from decoder: Decoder) throws {
        self =
            switch try decoder.singleValueContainer().decode(String.self) {
            case "scale":
                .scale
            default:
                .unknown
            }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .scale:
            try container.encode("scale")
        case .unknown:
            try container.encode("unknown")
        }
    }
}
