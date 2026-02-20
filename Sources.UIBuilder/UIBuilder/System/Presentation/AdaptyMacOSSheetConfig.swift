//
//  AdaptyMacOSSheetConfig.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 18.02.2026.
//

import CoreGraphics
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package struct AdaptyMacOSSheetConfig: Sendable, Equatable {
    package let presentationType: AdaptyMacOSSheetPresentationType
    package let dismissPolicy: AdaptyMacOSSheetDismissPolicy
    package let windowType: AdaptyMacOSSheetWindowType

    package init(
        presentationType: AdaptyMacOSSheetPresentationType = .borderlessCustom,
        dismissPolicy: AdaptyMacOSSheetDismissPolicy = .init(),
        windowType: AdaptyMacOSSheetWindowType = .init()
    ) {
        self.presentationType = presentationType
        self.dismissPolicy = dismissPolicy
        self.windowType = windowType
    }

    package static let `default` = Self()
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package enum AdaptyMacOSSheetPresentationType: Sendable, Equatable {
    case borderlessCustom
    case titledSystemWindow(title: String)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package struct AdaptyMacOSSheetDismissPolicy: Sendable, Equatable {
    package let dismissableByOutsideClick: Bool
    package let dismissableByEsc: Bool
    package let dismissableByCustomKeyboardShortcut: AdaptyCustomKeyboardShortcut?

    package init(
        dismissableByOutsideClick: Bool = true,
        dismissableByEsc: Bool = true,
        dismissableByCustomKeyboardShortcut: AdaptyCustomKeyboardShortcut? = nil
    ) {
        self.dismissableByOutsideClick = dismissableByOutsideClick
        self.dismissableByEsc = dismissableByEsc
        self.dismissableByCustomKeyboardShortcut = dismissableByCustomKeyboardShortcut
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package struct AdaptyMacOSSheetWindowType: Sendable, Equatable {
    package let baseSize: CGSize?
    package let resizable: Bool

    package init(
        baseSize: CGSize? = nil,
        resizable: Bool = true
    ) {
        self.baseSize = baseSize
        self.resizable = resizable
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package struct AdaptyCustomKeyboardShortcut: Sendable, Equatable {
    package let key: String
    package let modifiers: AdaptyMacOSSheetKeyboardModifiers

    package init(
        key: String,
        modifiers: AdaptyMacOSSheetKeyboardModifiers
    ) {
        self.key = key
        self.modifiers = modifiers
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package struct AdaptyMacOSSheetKeyboardModifiers: OptionSet, Sendable, Hashable {
    package let rawValue: Int

    package init(rawValue: Int) {
        self.rawValue = rawValue
    }

    package static let command = Self(rawValue: 1 << 0)
    package static let option = Self(rawValue: 1 << 1)
    package static let control = Self(rawValue: 1 << 2)
    package static let shift = Self(rawValue: 1 << 3)
}
