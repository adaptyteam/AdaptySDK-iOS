//
//  VerticalAlignment.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package enum VerticalAlignment: String {
        case top
        case center
        case bottom
        case justified
    }
}

extension AdaptyViewConfiguration.VerticalAlignment: Decodable {}
