//
//  SwiftUI+Alignment.swift
//
//
//  Created by Aleksey Goncharov on 14.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
extension Alignment {
    static func from(
        horizontal: HorizontalAlignment,
        vertical: VerticalAlignment
    ) -> Alignment {
        switch (vertical, horizontal) {
        case (.top, .leading): .topLeading
        case (.top, .center): .top
        case (.top, .trailing): .topTrailing
        case (.center, .leading): .leading
        case (.center, .center): .center
        case (.center, .trailing): .trailing
        case (.bottom, .leading): .bottomLeading
        case (.bottom, .center): .bottom
        case (.bottom, .trailing): .bottomTrailing
        default: .center
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.HorizontalAlignment {
    func swiftuiValue(with layoutDirection: LayoutDirection) -> SwiftUI.HorizontalAlignment {
        switch self {
        case .leading: SwiftUI.HorizontalAlignment.leading
        case .trailing: SwiftUI.HorizontalAlignment.trailing
        case .center: SwiftUI.HorizontalAlignment.center
        case .justified: SwiftUI.HorizontalAlignment.center
        case .left:
            switch layoutDirection {
            case .leftToRight: SwiftUI.HorizontalAlignment.leading
            case .rightToLeft: SwiftUI.HorizontalAlignment.trailing
            @unknown default: SwiftUI.HorizontalAlignment.leading
            }
        case .right:
            switch layoutDirection {
            case .leftToRight: SwiftUI.HorizontalAlignment.trailing
            case .rightToLeft: SwiftUI.HorizontalAlignment.leading
            @unknown default: SwiftUI.HorizontalAlignment.trailing
            }
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.VerticalAlignment {
    var swiftuiValue: SwiftUI.VerticalAlignment {
        switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        case .justified: .center
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Stack {
    func swiftuiValue(with layoutDirection: LayoutDirection) -> Alignment {
        Alignment.from(
            horizontal: horizontalAlignment.swiftuiValue(with: layoutDirection),
            vertical: verticalAlignment.swiftuiValue
        )
    }
}

#endif
