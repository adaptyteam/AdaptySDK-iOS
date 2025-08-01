//
//  AdaptyUIBackgroundModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIBackgroundModifier: ViewModifier {
    var background: VC.Background?

    @EnvironmentObject
    private var assetsViewModel: AdaptyAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    func body(content: Content) -> some View {
        switch self.background {
        case let .image(imageData):
            content
                .background {
                    AdaptyUIImageView(
                        asset: imageData.usedColorScheme(self.colorScheme),
                        aspect: .fill,
                        tint: nil
                    )
                    .ignoresSafeArea()
                }
        case let .filling(filling):
            content
                .background {
                    Rectangle()
                        .fill(
                            filling,
                            colorScheme: self.colorScheme,
                            assetsResolver: self.assetsViewModel.assetsResolver
                        )
                        .ignoresSafeArea()
                }
        case .none:
            content
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func staticBackground(_ background: VC.Background?) -> some View {
        if let background {
            modifier(AdaptyUIBackgroundModifier(background: background))
        } else {
            self
        }
    }
}

#endif
