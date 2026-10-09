//
//  Font+UIKit.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

#if canImport(UIKit)

import UIKit

extension UIFont.Weight {
    static func fromInteger(_ value: Int) -> UIFont.Weight {
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

extension UIFont {
    static func customFont(
        ofSize size: CGFloat,
        name: String,
        weight: Int,
        italic: Bool
    ) -> UIFont {
        var traits: [UIFontDescriptor.TraitKey: Any] = [
            .weight: UIFont.Weight.fromInteger(weight),
        ]

        // `withSymbolicTraits` builds a fresh descriptor and drops the numeric weight
        // trait, so italic has to travel in the same dictionary as the weight.
        if italic {
            traits[.symbolic] = UIFontDescriptor.SymbolicTraits.traitItalic.rawValue
        }

        let descriptor = UIFontDescriptor(fontAttributes: [
            .family: name,
            .traits: traits,
        ])

        return UIFont(descriptor: descriptor, size: size)
    }
}

@MainActor
extension UIFont {
    private static let systemFontReservedName = "adapty_system"

    static func create(_ font: VC.Font, withSize size: Double) -> UIFont {
        if !font.alias.isEmpty,
           let font = AdaptyUIBuilder.internalFontsResolver?.internalFont(
               for: font.alias,
               size: size
           )
        {
            return font
        }

        if !font.alias.isEmpty, let font = UIFont(name: font.alias, size: size) {
            return font
        }

        if font.familyName == systemFontReservedName {
            return .systemFont(
                ofSize: size,
                weight: .fromInteger(font.weight),
                italic: font.italic
            )
        }

        return .customFont(ofSize: size,
                           name: font.familyName,
                           weight: font.weight,
                           italic: font.italic)
    }
}

extension UIFont {
    static func systemFont(ofSize fontSize: CGFloat, weight: UIFont.Weight, italic: Bool) -> UIFont {
        let font = UIFont.systemFont(ofSize: fontSize, weight: weight)

        guard italic,
              let italicDescriptor = font.fontDescriptor.withItalicSymbolicTraits(weight: weight)
        else {
            return font
        }

        return UIFont(descriptor: italicDescriptor, size: fontSize)
    }
}

extension UIFontDescriptor {
    func withItalicSymbolicTraits(weight: UIFont.Weight) -> UIFontDescriptor? {
        switch weight {
        case .bold, .heavy, .black:
            return withSymbolicTraits([.traitItalic, .traitBold])
        default:
            return withSymbolicTraits([.traitItalic])
        }
    }
}

#endif
