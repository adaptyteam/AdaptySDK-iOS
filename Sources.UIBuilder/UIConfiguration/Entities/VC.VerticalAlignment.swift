//
//  VC.VerticalAlignment.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    enum VerticalAlignment: String {
        case top
        case center
        case bottom
        case justified
    }
}

extension VC.VerticalAlignment: Codable {}
