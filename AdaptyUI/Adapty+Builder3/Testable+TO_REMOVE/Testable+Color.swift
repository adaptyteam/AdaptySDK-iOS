//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if DEBUG

@testable import Adapty

@available(iOS 13.0, *)
extension AdaptyUI.Color {
    static let testWhite = AdaptyUI.Color(data: 0xFFFFFFFF)
    static let testClear = AdaptyUI.Color(data: 0xFFFFFF00)
    static let testRed = AdaptyUI.Color(data: 0xFF0000FF)
    static let testGreen = AdaptyUI.Color(data: 0x00FF00FF)
    static let testBlue = AdaptyUI.Color(data: 0x0000FFFF)
}

#endif
