//
//  AdaptyUIFlatContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUIFlatContainerView: View {
    @State
    private var footerSize: CGSize = .zero
    @State
    private var drawFooterBackground = false

    var screen: VC.Screen

    @ViewBuilder
    private func footerView(
        _ element: VC.Element,
        globalProxy: GeometryProxy
    ) -> some View {
        if footerSize.height >= globalProxy.size.height {
            ScrollView {
                AdaptyUIElementView(
                    element,
                    screenHolderBuilder: { EmptyView() }, // TODO: x check
                    drawDecoratorBackground: drawFooterBackground
                )
            }
            .scrollIndicatorsHidden_compatible()
        } else {
            AdaptyUIElementView(
                element,
                screenHolderBuilder: { EmptyView() }, // TODO: x check
                drawDecoratorBackground: drawFooterBackground
            )
        }
    }

    var body: some View {
        GeometryReader { globalProxy in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack {
                        AdaptyUIElementView(
                            screen.content,
                            screenHolderBuilder: { EmptyView() } // TODO: x check
                        )
                        .frame(maxWidth: .infinity)

                        FooterVerticalFillerView(height: footerSize.height) { frame in
                            withAnimation {
                                drawFooterBackground = frame.maxY > globalProxy.size.height + globalProxy.safeAreaInsets.bottom
                            }
                        }
                    }
                }
                .scrollIndicatorsHidden_compatible()

                if let footer = screen.footer {
                    footerView(footer, globalProxy: globalProxy)
                        .onGeometrySizeChange { footerSize = $0 }
                }

                if let overlay = screen.overlay {
                    AdaptyUIElementView(
                        overlay,
                        screenHolderBuilder: { EmptyView() } // TODO: x check
                    )
                }
            }
            .ignoresSafeArea()
        }
        .coordinateSpace(name: CoordinateSpace.adaptyGlobalName)
    }
}

#endif
