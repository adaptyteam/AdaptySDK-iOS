//
//  VC.Variable.Convertor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension VC.Variable {
    protocol Converter: Sendable, Hashable {}
    struct UnknownConverter: Converter {
        let name: String
    }
}

extension VC.Variable.Converter {
    func isEqual(to other: any VC.Variable.Converter) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

