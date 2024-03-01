//
//  AdaptyExtended.swift
//
//
//  Created by Aleksei Valiano on 27.02.2024
//
//

import Foundation

internal struct AdaptyExtension<Extended> {
    let this: Extended

    fileprivate init(_ this: Extended) {
        self.this = this
    }
}

internal protocol AdaptyExtended {
    associatedtype Extended

    static var ext: AdaptyExtension<Extended>.Type { get }

    var ext: AdaptyExtension<Extended> { get }
}

internal extension AdaptyExtended {
    static var ext: AdaptyExtension<Self>.Type {
        AdaptyExtension<Self>.self
    }

    var ext: AdaptyExtension<Self> {
        AdaptyExtension(self)
    }
}
