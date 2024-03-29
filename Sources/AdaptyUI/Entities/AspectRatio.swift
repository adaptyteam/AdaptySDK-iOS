//
//  AspectRatio.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

import Foundation

extension AdaptyUI {
    public enum AspectRatio: String {
        case fit
        case fill
        case stretch
    }
}

extension AdaptyUI.AspectRatio: Decodable {}
