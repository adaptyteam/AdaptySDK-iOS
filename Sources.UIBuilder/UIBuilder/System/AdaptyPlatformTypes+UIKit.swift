//
//  AdaptyPlatformTypes+UIKit.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 18.02.2026.
//

#if canImport(UIKit)

import UIKit

public extension AdaptyPlatformImage {
    init(uiImage: UIImage) {
        self.init(uiImage)
    }

    var uiImage: UIImage {
        native
    }
}

public extension AdaptyPlatformColor {
    init(uiColor: UIColor) {
        self.init(uiColor)
    }

    var uiColor: UIColor {
        native
    }
}

public extension AdaptyPlatformFont {
    init(uiFont: UIFont) {
        self.init(uiFont)
    }

    var uiFont: UIFont {
        native
    }
}

#endif
