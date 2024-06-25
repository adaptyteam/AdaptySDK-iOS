//
//  AdaptyUIFlatContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUIFlatContainerView: View {
    @State
    private var footerSize: CGSize = .zero

    var screen: AdaptyUI.Screen

    @ViewBuilder
    private func footerView(
        _ element: AdaptyUI.Element,
        globalProxy: GeometryProxy
    ) -> some View {
        if footerSize.height >= globalProxy.size.height {
            ScrollView {
                AdaptyUIElementView(element)
            }
            .scrollIndicatorsHidden_compatible()
        } else {
            AdaptyUIElementView(element)
        }
    }

    var body: some View {
        GeometryReader { p in
            ZStack(alignment: .bottom) {
                ScrollView {
                    AdaptyUIElementView(screen.content)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, footerSize.height)
                }
                .scrollIndicatorsHidden_compatible()

                if let footer = screen.footer {
                    footerView(footer, globalProxy: p)
                        .onGeometrySizeChange { footerSize = $0 }
                }

                if let overlay = screen.overlay {
                    AdaptyUIElementView(overlay)
                }
            }
            .coordinateSpace(name: CoordinateSpace.adaptyBasicName)
            .ignoresSafeArea()
        }
    }
}

#endif
