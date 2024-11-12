//
//  AdaptyUIAlignmentModifier.swift
//
//
//  Created by Aleksey Goncharov on 12.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUICore.HorizontalAlignment {
    func textAlignment(with layoutDirection: LayoutDirection) -> TextAlignment {
        switch self {
        case .leading: TextAlignment.leading
        case .trailing: TextAlignment.trailing
        case .center: TextAlignment.center
        case .justified: TextAlignment.center
        case .left:
            switch layoutDirection {
            case .leftToRight: TextAlignment.leading
            case .rightToLeft: TextAlignment.trailing
            @unknown default: TextAlignment.leading
            }
        case .right:
            switch layoutDirection {
            case .leftToRight: TextAlignment.trailing
            case .rightToLeft: TextAlignment.leading
            @unknown default: TextAlignment.trailing
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAlignmentModifier: ViewModifier {
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    var alignment: AdaptyUICore.HorizontalAlignment

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(alignment.textAlignment(with: layoutDirection))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func multilineTextAlignment(_ alignment: AdaptyUICore.HorizontalAlignment) -> some View {
        modifier(AdaptyUIAlignmentModifier(alignment: alignment))
    }
}

#endif
