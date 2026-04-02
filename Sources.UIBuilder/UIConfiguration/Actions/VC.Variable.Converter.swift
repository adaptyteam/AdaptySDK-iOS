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
        case dateTimeWithFormat(String)
        case dateTimeWithStyle(DateFormatter.Style, DateFormatter.Style)

        case unknown(String, VC.Parameter?)
    }
}

extension DateFormatter.Style {
    init?(fromString: String) {
        switch fromString {
        case "none":
            self = .none
        case "full":
            self = .full
        case "long":
            self = .long
        case "medium":
            self = .medium
        case "short":
            self = .short
        default:
            return nil
        }
    }

    var stringValue: String {
        switch self {
        case .none:
            "none"
        case .full:
            "full"
        case .long:
            "long"
        case .medium:
            "medium"
        case .short:
            "short"
        @unknown default:
            "none"
        }
    }
}

