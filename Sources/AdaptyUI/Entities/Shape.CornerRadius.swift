//
//  Shape.CornerRadius.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.07.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.Shape {
    public enum CornerRadius {
        case none
        case same(Double)
        case different(topLeft: Double, topRight: Double, bottomRight: Double, bottomLeft: Double)

        public var value: Double? { topLeft }

        public var topLeft: Double? {
            switch self {
            case .none: return nil
            case let .same(value): return value
            case let .different(value, _, _, _): return value
            }
        }

        public var topRight: Double? {
            switch self {
            case .none: return nil
            case let .same(value): return value
            case let .different(_, value, _, _): return value
            }
        }

        public var bottomRight: Double? {
            switch self {
            case .none: return nil
            case let .same(value): return value
            case let .different(_, _, value, _): return value
            }
        }

        public var bottomLeft: Double? {
            switch self {
            case .none: return nil
            case let .same(value): return value
            case let .different(_, _, _, value): return value
            }
        }
    }
}
