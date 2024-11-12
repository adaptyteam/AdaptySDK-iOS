//
//  AspectRatio.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUICore {
    package enum AspectRatio: String {
        case fit
        case fill
        case stretch
    }
}

extension AdaptyUICore.AspectRatio: Decodable {}
