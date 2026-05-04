//
//  AdaptyUIAlignmentModifier.swift
//
//
//  Created by Aleksey Goncharov on 12.06.2024.
//

#if canImport(UIKit)

import SwiftUI

extension VC.HorizontalAlignment {
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

struct AdaptyUIAlignmentModifier: ViewModifier {
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    var alignment: VC.HorizontalAlignment

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(alignment.textAlignment(with: layoutDirection))
    }
}

extension View {
    @ViewBuilder
    func multilineTextAlignment(_ alignment: VC.HorizontalAlignment) -> some View {
        modifier(AdaptyUIAlignmentModifier(alignment: alignment))
    }
}

#endif
