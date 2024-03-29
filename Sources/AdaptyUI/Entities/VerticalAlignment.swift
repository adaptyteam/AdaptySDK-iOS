//
//  VerticalAlignment.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    public enum VerticalAlignment: String {
        case top
        case center
        case bottom
        case fill
    }
}

extension AdaptyUI.VerticalAlignment: Decodable {}
