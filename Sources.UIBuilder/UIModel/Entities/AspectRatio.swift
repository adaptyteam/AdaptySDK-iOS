//
//  AspectRatio.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package enum AspectRatio: String {
        case fit
        case fill
        case stretch
    }
}

extension AdaptyViewConfiguration.AspectRatio: Codable {}
