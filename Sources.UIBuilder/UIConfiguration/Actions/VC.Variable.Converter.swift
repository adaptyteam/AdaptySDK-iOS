//
//  VC.Variable.Converter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.02.2026.
//

import Foundation

extension VC.Variable {
    enum Converter: Sendable, Hashable {
        case isEqual(VC.Parameter, falseValue: VC.Parameter?)
        case unknown(String, VC.Parameter?)
    }
}
