//
//  File.swift
//  
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if DEBUG

@testable import Adapty
import Foundation

@available(iOS 15.0, *)
extension AdaptyUI.Screen {
    static var testBasicDog: Self {
        .create(
            background: .color(.testWhite),
            cover: .box(.testBasicDog, nil),
            content: .stack(.testVStackBig, .blueBG),
            footer: .stack(.testHStack, .redBG)
        )
    }
    
    static var testFlatDog: Self {
        .create(
            background: .color(.testWhite),
            content: .stack(.testVStackBigAndDog, .blueBG),
            footer: .stack(.testHStack, .redBG),
            overlay: .text(.testBodyLong, nil)
        )
    }
    
    static var testTransparent: Self {
        .create(
            background: .color(.testWhite),
            content: .box(.testBasicDog, nil),
            footer: .stack(.testVStackMediumAndDog, .greenBG),
            overlay: .text(.testBodyShort, nil)
        )
    }
    
    static var testTransparentScroll: Self {
        .create(
            background: .color(.testWhite),
            content: .box(.testBasicDog, nil),
            footer: .stack(.testVStackBigAndDog, .greenBG),
            overlay: .text(.testBodyShort, nil)
        )
    }
}

#endif
