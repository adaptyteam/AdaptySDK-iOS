//
//  VC.PercentConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.04.2026.
//

import Foundation

extension VC {
    struct PercentConverter: Converter {
        let format: String
    }
}

extension VC.PercentConverter: VC.TagConverter {
    func toString(_ value: Any) -> String? {
        switch value {
        case let value as Double:
            toString(percent: value)
        case let value as NSNumber:
            toString(percent: value)
        default:
            nil
        }
    }
}

extension VC.PercentConverter {
    @inlinable
    func toString(percent: NSNumber) -> String {
        toString(percent: percent.doubleValue)
    }

    @inlinable
    func toString(percent: Double) -> String {
        let percent = min(1, max(0, percent)) * 100

        return if format.hasSuffix("d") {
            String(format: format, Int(percent))
        } else {
            String(format: format, percent)
        }
    }
}

