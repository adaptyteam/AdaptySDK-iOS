//
//  Schema.ColorGradient.Kind.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

extension Schema.ColorGradient.Kind: RawRepresentable {
    private enum Key {
        static let colorLinearGradient = "linear-gradient"
        static let colorRadialGradient = "radial-gradient"
        static let colorConicGradient = "conic-gradient"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.colorLinearGradient: self = .linear
        case Key.colorRadialGradient: self = .radial
        case Key.colorConicGradient: self = .conic
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .linear: Key.colorLinearGradient
        case .radial: Key.colorRadialGradient
        case .conic: Key.colorConicGradient
        }
    }
}

extension Schema.ColorGradient.Kind: Codable {}
