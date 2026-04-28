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
    func toString(_ value: Any, locale: Locale) -> String? {
        switch value {
        case let value as UInt:
            toString(number: value, locale: locale)
        case let value as Int:
            toString(number: value, locale: locale)
        case let value as Double:
            toString(number: value, locale: locale)
        case let value as NSNumber:
            toString(number: value, locale: locale)
        default:
            nil
        }
    }
}

extension VC.NumberConverter {
    @inlinable
    func toString(number: NSNumber, locale: Locale) -> String {
        if format.hasSuffix("d") {
            String(format: format, number)
        } else {
            String(format: format, number.doubleValue, separator: locale.decimalSeparator)
        }
    }

    @inlinable
    func toString(number: UInt, locale: Locale) -> String {
        if format.hasSuffix("d") {
            String(format: format, number)
        } else {
            String(format: format, Double(number), separator: locale.decimalSeparator)
        }
    }

    @inlinable
    func toString(number: Int, locale: Locale) -> String {
        if format.hasSuffix("d") {
            String(format: format, number)
        } else {
            String(format: format, Double(number), separator: locale.decimalSeparator)
        }
    }

    @inlinable
    func toString(number: Double, locale: Locale) -> String {
        if format.hasSuffix("d") {
            String(format: format, Int(number))
        } else {
            String(format: format, number, separator: locale.decimalSeparator)
        }
    }
}

extension String {
    init(format: String, _ double: Double, separator: String?) {
        if let separator, separator != "." {
            self = String(format: format, double).replacingOccurrences(of: ".", with: separator)
        } else {
            self.init(format: format, double)
        }
    }
}

