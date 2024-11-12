//
//  Text.OverflowMode.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension AdaptyUICore.Text {
    package enum OverflowMode: String {
        case scale
        case unknown
    }
}

extension AdaptyUICore.Text.OverflowMode: Decodable {
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
