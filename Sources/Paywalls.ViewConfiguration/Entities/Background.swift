//
//  Background.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension AdaptyUICore {
    enum Background: Sendable {
        static let `default` = Background.filling(.same(.default))

        case filling(Mode<Filling>)
        case image(Mode<ImageData>)

        package var asFilling: Mode<Filling>? {
            switch self {
            case let .filling(value): value
            default: nil
            }
        }

        package var asImage: Mode<ImageData>? {
            switch self {
            case let .image(value): value
            default: nil
            }
        }
    }
}

extension AdaptyUICore.Background: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .filling(value):
            hasher.combine(value)
        case let .image(value):
            hasher.combine(value)
        }
    }
}
