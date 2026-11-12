//
//  VC.BlendMode.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.10.2026
//

extension VC {
    enum BlendMode: Sendable, CaseIterable {
        case normal
        case multiply
        case screen
        case overlay
        case darken
        case lighten
        case colorDodge
        case colorBurn
        case hardLight
        case difference
        case exclusion
        case hue
        case saturation
        case color
        case luminosity
        case sourceAtop
        case destinationOver
        case destinationOut
        case destinationIn
        case plusLighter
    }
}
