//
//  VC.NumberConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.04.2026.
//

import Foundation

extension VC {
    struct NumberConverter: Converter {
        let format: String
    }
}

extension VC.NumberConverter: VC.TagConverter {
    func toString(_ value: Any) -> String? {
        switch value {
        case let value as UInt:
            toString(number: value)
        case let value as Int:
            toString(number: value)
        case let value as Double:
            toString(number: value)
        case let value as NSNumber:
            toString(number: value)
        default:
            nil
        }
    }
}

extension VC.NumberConverter {
    @inlinable
    func toString(number: NSNumber) -> String {
        if format.hasSuffix("d") {
            String(format: format, number)
        } else {
            String(format: format, number.doubleValue)
        }
    }

    @inlinable
    func toString(number: UInt) -> String {
        if format.hasSuffix("d") {
            String(format: format, number)
        } else {
            String(format: format, Double(number))
        }
    }

    @inlinable
    func toString(number: Int) -> String {
        if format.hasSuffix("d") {
            String(format: format, number)
        } else {
            String(format: format, Double(number))
        }
    }

    @inlinable
    func toString(number: Double) -> String {
        if format.hasSuffix("d") {
            String(format: format, Int(number))
        } else {
            String(format: format, number)
        }
    }
}

