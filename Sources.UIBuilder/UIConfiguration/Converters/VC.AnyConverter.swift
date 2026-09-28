//
//  VC.AnyConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

protocol VCConverter: Sendable {}

extension VC {
    struct AnyConverter: VCConverter {
        let wrapped: any VCConverter

        init(_ value: any VCConverter) {
            if let value = value as? AnyConverter {
                self = value
            } else {
                wrapped = value
            }
        }
    }

    struct UnknownConverter: VCConverter {
        let name: String
    }
}

extension VCConverter {
    @inlinable
    var asAnyConverter: VC.AnyConverter {
        .init(self)
    }
}
