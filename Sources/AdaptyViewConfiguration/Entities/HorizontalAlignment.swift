//
//  HorizontalAlignment.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyViewConfiguration {
    package enum HorizontalAlignment: String {
        case leading
        case trailing
        case left
        case center
        case right
        case justified
    }
}

extension AdaptyViewConfiguration.HorizontalAlignment: Codable {}
