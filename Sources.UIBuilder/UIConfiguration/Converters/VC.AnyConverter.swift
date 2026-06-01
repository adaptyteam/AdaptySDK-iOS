//
//  VC.AnyConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension VC {
    protocol Converter: Sendable {}

    struct AnyConverter: Converter {
        let wrapped: any Converter

        init(_ value: any Converter) {
            if let value = value as? AnyConverter {
                self = value
            } else {
                wrapped = value
            }
        }
    }

    struct UnknownConverter: Converter {
        let name: String
    }
}

extension VC.Converter {
    @inlinable
    var asAnyConverter: VC.AnyConverter {
        .init(self)
    }
}
