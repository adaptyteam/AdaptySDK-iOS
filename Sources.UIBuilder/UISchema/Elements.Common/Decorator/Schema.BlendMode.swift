//
//  Schema.BlendMode.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.10.2026.
//

import Foundation

extension Schema {
    typealias BlendMode = VC.BlendMode
}

extension Schema.BlendMode {
    static let `default`: Self = .normal
}

extension Schema.BlendMode: RawRepresentable {
    private enum Key {
        static let normal = "normal"
        static let multiply = "multiply"
        static let screen = "screen"
        static let overlay = "overlay"
        static let darken = "darken"
        static let lighten = "lighten"
        static let colorDodge = "color_dodge"
        static let colorBurn = "color_burn"
        static let hardLight = "hard_light"
        static let difference = "difference"
        static let exclusion = "exclusion"
        static let hue = "hue"
        static let saturation = "saturation"
        static let color = "color"
        static let luminosity = "luminosity"
        static let sourceAtop = "source_atop"
        static let destinationOver = "destination_over"
        static let destinationOut = "destination_out"
        static let destinationIn = "destination_in"
        static let plusLighter = "plus_lighter"
    }

    init?(rawValue value: String) {
        switch value {
        case Key.normal: self = .normal
        case Key.multiply: self = .multiply
        case Key.screen: self = .screen
        case Key.overlay: self = .overlay
        case Key.darken: self = .darken
        case Key.lighten: self = .lighten
        case Key.colorDodge: self = .colorDodge
        case Key.colorBurn: self = .colorBurn
        case Key.hardLight: self = .hardLight
        case Key.difference: self = .difference
        case Key.exclusion: self = .exclusion
        case Key.hue: self = .hue
        case Key.saturation: self = .saturation
        case Key.color: self = .color
        case Key.luminosity: self = .luminosity
        case Key.sourceAtop: self = .sourceAtop
        case Key.destinationOver: self = .destinationOver
        case Key.destinationOut: self = .destinationOut
        case Key.destinationIn: self = .destinationIn
        case Key.plusLighter: self = .plusLighter
        default: return nil
        }
    }

    var rawValue: String {
        switch self {
        case .normal: Key.normal
        case .multiply: Key.multiply
        case .screen: Key.screen
        case .overlay: Key.overlay
        case .darken: Key.darken
        case .lighten: Key.lighten
        case .colorDodge: Key.colorDodge
        case .colorBurn: Key.colorBurn
        case .hardLight: Key.hardLight
        case .difference: Key.difference
        case .exclusion: Key.exclusion
        case .hue: Key.hue
        case .saturation: Key.saturation
        case .color: Key.color
        case .luminosity: Key.luminosity
        case .sourceAtop: Key.sourceAtop
        case .destinationOver: Key.destinationOver
        case .destinationOut: Key.destinationOut
        case .destinationIn: Key.destinationIn
        case .plusLighter: Key.plusLighter
        }
    }
}

extension Schema.BlendMode: Codable {}
