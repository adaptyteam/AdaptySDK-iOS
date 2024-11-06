//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

#if canImport(UIKit)

import Adapty

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension AdaptyUI.Unit {
    func points(screenSize: Double, safeAreaStart: Double, safeAreaEnd: Double) -> Double {
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
