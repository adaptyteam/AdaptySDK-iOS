//
//  VerticalAlignment.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUIConfiguration {
    package enum VerticalAlignment: String {
        case top
        case center
        case bottom
        case justified
    }
}

extension AdaptyUIConfiguration.VerticalAlignment: Codable {}
