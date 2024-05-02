//
//  Text.OverflowMode.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension AdaptyUI.Text {
    package enum OverflowMode: String {
        case truncate
        case scale
    }
}

extension Set<AdaptyUI.Text.OverflowMode> {
    static let empty: Self = []
}

extension AdaptyUI.Text.OverflowMode: Decodable {}
