//
//  File.swift
//  
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if DEBUG

@testable import Adapty
import Foundation

@available(iOS 13.0, *)
extension AdaptyUI.Screen {
    static var testDog: Self {
        .init(
            background: .color(.testWhite),
            cover: .box(.testBasicDog, nil),
            content: .stack(.testVStackBig, .blueBG),
            footer: .stack(.testHStack, .redBG),
            overlay: nil
        )
    }
}

#endif
