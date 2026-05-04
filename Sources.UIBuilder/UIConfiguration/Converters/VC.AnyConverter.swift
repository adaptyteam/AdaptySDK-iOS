//
//  VC.AnyConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension VC {
    protocol Converter: Sendable, Hashable {}
    
    struct AnyConverter: Converter {
        let wrapped: any Converter

        init(_ value: any Converter) {
            if let value = value as? AnyConverter {
                self = value
            } else {
                wrapped = value
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            AnyHashable(lhs.wrapped) == AnyHashable(rhs.wrapped)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(AnyHashable(wrapped))
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
