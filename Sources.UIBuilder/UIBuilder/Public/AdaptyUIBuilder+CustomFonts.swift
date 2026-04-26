//
//  AdaptyUIBuilder+CustomFonts.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 24.04.2026.
//

#if canImport(UIKit)

import UIKit

public extension AdaptyUIBuilder {
    @MainActor
    static func setCustomFonts(_ fonts: [String: UIFont]) {
        AdaptyUICustomFontsStorage.setFonts(fonts)
    }
}

@MainActor
package enum AdaptyUICustomFontsStorage {
    private static var fonts: [String: UIFont] = [:]

    static func setFonts(_ fonts: [String: UIFont]) {
        self.fonts = fonts
    }

    static func font(for id: String) -> UIFont? {
        fonts[id]
    }
}

#endif
