//
//  AdaptyUIPaddingDecorator.swift
//
//
//  Created by Aleksey Goncharov on 26.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIPaddingDecorator: ViewModifier {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    var insets: AdaptyUI.EdgeInsets?

    func body(content: Content) -> some View {
        if let insets {
            content
                .padding(
                    EdgeInsets(
                        top: insets.top.points(screenSize: screenSize.height,
                                               safeAreaStart: safeArea.top,
                                               safeAreaEnd: safeArea.bottom),
                        leading: insets.leading.points(screenSize: screenSize.width,
                                                       safeAreaStart: safeArea.leading,
                                                       safeAreaEnd: safeArea.trailing),
                        bottom: insets.bottom.points(screenSize: screenSize.height,
                                                     safeAreaStart: safeArea.top,
                                                     safeAreaEnd: safeArea.bottom),
                        trailing: insets.trailing.points(screenSize: screenSize.width,
                                                         safeAreaStart: safeArea.leading,
                                                         safeAreaEnd: safeArea.trailing)
                    )
                )
        } else {
            content
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func padding(_ insets: AdaptyUI.EdgeInsets?) -> some View {
        if let insets {
            modifier(AdaptyUIPaddingDecorator(insets: insets))
        } else {
            self
        }
    }
}

#endif
