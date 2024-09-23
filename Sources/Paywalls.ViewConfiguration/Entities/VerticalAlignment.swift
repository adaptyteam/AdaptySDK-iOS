//
//  VerticalAlignment.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    package enum VerticalAlignment: String {
        case top
        case center
        case bottom
        case justified
    }
}

extension AdaptyUI.VerticalAlignment: Decodable {}
