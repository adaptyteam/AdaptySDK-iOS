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
                AdaptyUIElementView(element)
                    .id("content")
                    .onGeometrySizeChange { footerSize = $0 }
                    .padding(.top, max(0, additionalTopPadding))
            }
            .scrollIndicatorsHidden_compatible()
            .onAppear {
                DispatchQueue.baseUrl.async {
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
                    AdaptyUIElementView(overlay)
                }
            }
            .ignoresSafeArea()
        }
    }
}

#endif
