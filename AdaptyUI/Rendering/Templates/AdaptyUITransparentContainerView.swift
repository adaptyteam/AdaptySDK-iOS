//
//  AdaptyUITransparentContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUITransparentContainerView: View {
    var screen: AdaptyUI.Screen

    @State var footerSize: CGSize = .zero

    @ViewBuilder
    private func scrollableFooterView(
        _ element: AdaptyUI.Element,
        globalProxy: GeometryProxy
    ) -> some View {
        let additionalTopPadding = globalProxy.size.height - footerSize.height + globalProxy.safeAreaInsets.top + globalProxy.safeAreaInsets.bottom

        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: 0) {
                    if additionalTopPadding > 0 {
                        Color.clear
                            .frame(height: additionalTopPadding)
                    }

                    AdaptyUIElementView(
                        element,
                        additionalPadding: globalProxy.safeAreaInsets
                    )
                    .id("content")
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    footerSize = geometry.size
                                }
                        }
                    )
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    scrollProxy.scrollTo("content", anchor: .bottom)
                }
            }
        }
    }

    var body: some View {
        GeometryReader { p in
            ZStack(alignment: .bottom) {
                AdaptyUIElementView(screen.content)

                if let footer = screen.footer {
                    scrollableFooterView(
                        footer,
                        globalProxy: p
                    )
                }

                if let overlay = screen.overlay {
                    AdaptyUIElementView(
                        overlay,
                        additionalPadding: p.safeAreaInsets
                    )
                }
            }
            .ignoresSafeArea()
        }
    }
}

#endif
