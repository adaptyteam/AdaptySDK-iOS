//
//  VC.IsEqualConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

extension VC {
    struct IsEqualConverter: VCConverter {
        let value: VC.AnyValue
        let falseValue: VC.AnyValue?
    }
}
