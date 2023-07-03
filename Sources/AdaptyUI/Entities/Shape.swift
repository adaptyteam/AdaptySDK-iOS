//
//  Shape.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.06.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct Shape {
        static let defaultMask = Mask.rectangle(cornerRadius: .none)
        public let background: Filling?
        public let mask: Mask
    }
}

extension AdaptyUI.Shape {
    public enum Mask {
        case rectangle(cornerRadius: CornerRadius)
        case circle
        case curveUp
        case curveDown
    }

    public enum CornerRadius {
        case none
        case same(Double)
        case different(topLeft: Double, topRight: Double, bottomRight: Double, bottomLeft: Double)

        var value: Double? { topLeft }

        var topLeft: Double? {
            switch self {
            case .none: return nil
            case let .same(value): return value
            case let .different(value, _, _, _): return value
            }
        }

        var topRight: Double? {
            switch self {
            case .none: return nil
            case let .same(value): return value
            case let .different(_, value, _, _): return value
            }
        }

        var bottomRight: Double? {
            switch self {
            case .none: return nil
            case let .same(value): return value
            case let .different(_, _, value, _): return value
            }
        }

        var bottomLeft: Double? {
            switch self {
            case .none: return nil
            case let .same(value): return value
            case let .different(_, _, _, value): return value
            }
        }
    }
}
