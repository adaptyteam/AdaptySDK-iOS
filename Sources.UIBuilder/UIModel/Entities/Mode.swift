//
//  Mode.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.08.2024
//
//

import Foundation

package extension AdaptyViewConfiguration {
    enum Mode<T>: Sendable, Hashable where T: Sendable, T: Hashable {
        case same(T)
        case different(light: T, dark: T)

        package enum Name: Int {
            case light
            case dark
        }

        package var isDifferent: Bool {
            if case .different = self { true } else { false }
        }

        package func mode(_ name: Name) -> T {
            switch self {
            case let .same(value):
                value
            case let .different(value1, value2):
                name == .light ? value1 : value2
            }
        }

        init(light: T, dark: T?) {
            guard let dark else {
                self = .same(light)
                return
            }

            self = .different(light: light, dark: dark)
        }
    }
}
