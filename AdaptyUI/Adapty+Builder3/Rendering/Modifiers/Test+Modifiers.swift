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
        .init(shapeType: .rectangle(cornerRadius: .zero),
              background: .color(.testGreen),
              border: nil)
    }
    
    static var blueBG: Self {
        .init(shapeType: .rectangle(cornerRadius: .zero),
              background: .color(.testBlue),
              border: nil)
    }
    
    static var redBG: Self {
        .init(shapeType: .rectangle(cornerRadius: .zero),
              background: .color(.testRed),
              border: nil)
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Element.Properties {
    static var greenBG: Self {
        .init(decorator: .greenBG,
              padding: .zero,
              offset: .zero,
              visibility: true,
              transitionIn: [])
    }
    
    static var blueBG: Self {
        .init(decorator: .blueBG,
              padding: .zero,
              offset: .zero,
              visibility: true,
              transitionIn: [])
    }
    
    static var redBG: Self {
        .init(decorator: .redBG,
              padding: .zero,
              offset: .zero,
              visibility: true,
              transitionIn: [])
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Box {
    static var test: Self {
        .init(width: .fixed(.screen(0.8)),
              height: .min(.point(48)),
              horizontalAlignment: .right,
              verticalAlignment: .center,
              content: .text(.testBodyShort, nil))
    }
}

@available(iOS 15.0, *)
#Preview {
    AdaptyUIElementView(.box(.test, .greenBG))
        .withScreenSize(UIScreen.main.bounds.size)
}

#endif
