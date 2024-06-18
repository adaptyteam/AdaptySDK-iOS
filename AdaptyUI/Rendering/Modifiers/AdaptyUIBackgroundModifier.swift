//
//  AdaptyUIBackgroundModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUIBackgroundModifier: ViewModifier {
    var background: AdaptyUI.Filling?

    func body(content: Content) -> some View {
        switch self.background {
        case .image(let imageData):
            content
                .background {
                    AdaptyUIImageView(asset: imageData,
                                      aspect: .fill,
                                      tint: nil)
                        .ignoresSafeArea()
                }
        default:
            content
                .background {
                    Rectangle()
                        .fill(filling: self.background)
                        .ignoresSafeArea()
                }
        }
    }
}

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func decorate(with background: AdaptyUI.Filling?) -> some View {
        if let background {
            modifier(AdaptyUIBackgroundModifier(background: background))
        } else {
            self
        }
    }
}

#endif
