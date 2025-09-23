//
//  HorizontalAlignment.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUIConfiguration {
    package enum HorizontalAlignment: String {
        case leading
        case trailing
        case left
        case center
        case right
        case justified
    }
}

extension AdaptyUIConfiguration.HorizontalAlignment: Codable {}
