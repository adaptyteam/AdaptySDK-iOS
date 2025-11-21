//
//  VC.AspectRatio.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    enum AspectRatio: String {
        case fit
        case fill
        case stretch
    }
}

extension VC.AspectRatio: Codable {}
