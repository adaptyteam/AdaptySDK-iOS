//
//  VC.Background.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension VC {
    enum Background: Sendable, Hashable {
        case filling(Mode<Filling>)
        case image(Mode<ImageData>)
    }
}

package extension VC.Background {
    var asFilling: VC.Mode<VC.Filling>? {
        switch self {
        case let .filling(value): value
        default: nil
        }
    }

    var asImage: VC.Mode<VC.ImageData>? {
        switch self {
        case let .image(value): value
        default: nil
        }
    }
}

extension VC.Background {
    static let `default` = Self.filling(.same(.default))
}
