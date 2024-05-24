//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if DEBUG

import Adapty
import AdaptyUI

@available(iOS 13.0, *)
extension AdaptyUI.Color {
    static let testBlack: AdaptyUI.Color = .create(data: 0x000000FF)
    static let testWhite: AdaptyUI.Color = .create(data: 0xFFFFFFFF)
    static let testClear: AdaptyUI.Color = .create(data: 0xFFFFFF00)
    static let testRed: AdaptyUI.Color = .create(data: 0xFF0000FF)
    static let testGreen: AdaptyUI.Color = .create(data: 0x00FF00FF)
    static let testBlue: AdaptyUI.Color = .create(data: 0x0000FFFF)
}

#endif
