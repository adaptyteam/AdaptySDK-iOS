//
//  VC.Variable.IsEqualConvertor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension VC.Variable {
    struct IsEqualConvertor: Converter {
        let value: VC.AnyValue
        let falseValue: VC.AnyValue?
    }
}

