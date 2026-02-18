//
//  Font+AppKit.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 18.02.2026.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

extension NSFont.Weight {
    static func fromInteger(_ value: Int) -> NSFont.Weight {
        switch value {
        case ..<150: return .ultraLight
        case ..<250: return .thin
        case ..<350: return .light
        case ..<450: return .regular
        case ..<550: return .medium
        case ..<650: return .semibold
        case ..<750: return .bold
        case ..<850: return .heavy
        default: return .black
        }
    }
}

extension NSFont {
    private static let systemFontReservedName = "adapty_system"

    static func create(_ font: VC.Font, withSize size: Double) -> AdaptyPlatformFont {
        if !font.alias.isEmpty, let font = NSFont(name: font.alias, size: size) {
            return AdaptyPlatformFont(font)
        }

        let result: NSFont
        if font.familyName == systemFontReservedName {
            result = NSFont.systemFont(ofSize: size, weight: .fromInteger(font.weight))
        } else {
            let base = NSFont(name: font.familyName, size: size)
                ?? NSFont.systemFont(ofSize: size, weight: .fromInteger(font.weight))
            result = base
        }

        if font.italic {
            let italicFont = NSFontManager.shared.convert(result, toHaveTrait: .italicFontMask)
            return AdaptyPlatformFont(italicFont.withSize(size))
        }

        return AdaptyPlatformFont(result)
    }
}

#endif
