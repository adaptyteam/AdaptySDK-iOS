//
//  HorizontalAlign.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public enum HorizontalAlign: String {
        case left
        case center
        case right
    }
}

extension AdaptyUI.HorizontalAlign: Decodable {
}
