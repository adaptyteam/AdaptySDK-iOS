//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

#if canImport(UIKit)

import Adapty

@available(iOS 15.0, *)
package extension AdaptyUI.Unit {
    package func points(screenSize: Double, safeAreaStart: Double, safeAreaEnd: Double) -> Double {
        switch self {
        case let .point(value): value
        case let .screen(value): value * screenSize
        case let .safeArea(value):
            switch value {
            case .start: safeAreaStart
            case .end: safeAreaEnd
            }
        }
    }
}

#endif
