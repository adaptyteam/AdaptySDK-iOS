//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if DEBUG && canImport(UIKit)

@testable import Adapty
import SwiftUI

@available(iOS 15.0, *)
extension AdaptyUI.Decorator {
    static var greenBG: Self {
        .create(
            background: .color(.testGreen)
        )
    }
    
    static var blueBG: Self {
        .create(
            background: .color(.testBlue)
        )
    }
    
    static var redBG: Self {
        .create(
            background: .color(.testRed)
        )
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Element.Properties {
    static var greenBG: Self {
        .create(decorator: .greenBG)
    }
    
    static var blueBG: Self {
        .create(decorator: .blueBG)
    }
    
    static var redBG: Self {
        .create(decorator: .redBG)
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Box {
    static var test: Self {
        .create(
            width: .fixed(.screen(0.8)),
            height: .min(.point(48)),
            horizontalAlignment: .right,
            verticalAlignment: .center,
            content: .text(.testBodyShort, nil)
        )
    }
}

@available(iOS 15.0, *)
#Preview {
    AdaptyUIElementView(.box(.test, .greenBG))
        .withScreenSize(UIScreen.main.bounds.size)
}

#endif
