//
//  AdaptyUIFlatContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 13.0, *)
struct AdaptyUIFlatContainerView: View {
    var screen: AdaptyUI.Screen

    @State var footerSize: CGSize = .zero

    @ViewBuilder
    private func staticFooterView(
        _ element: AdaptyUI.Element,
        globalProxy: GeometryProxy
    ) -> some View {
        AdaptyUIElementView(
            element,
            additionalPadding: EdgeInsets(
                top: 0,
                leading: 0,
                bottom: globalProxy.safeAreaInsets.bottom,
                trailing: 0
            )
        )
    }

    @ViewBuilder
    private func scrollableFooterView(
        _ element: AdaptyUI.Element,
        globalProxy: GeometryProxy
    ) -> some View {
        ScrollView {
            AdaptyUIElementView(
                element,
                additionalPadding: EdgeInsets(
                    top: globalProxy.safeAreaInsets.top,
                    leading: 0,
                    bottom: globalProxy.safeAreaInsets.bottom,
                    trailing: 0
                )
            )
        }
    }

    @ViewBuilder
    private func footerView(
        _ element: AdaptyUI.Element,
        globalProxy: GeometryProxy
    ) -> some View {
        if footerSize.height > globalProxy.size.height {
            scrollableFooterView(element, globalProxy: globalProxy)

        } else {
            staticFooterView(element, globalProxy: globalProxy)
        }
    }

    var body: some View {
        GeometryReader { p in
            ZStack(alignment: .bottom) {
                ScrollView {
                    AdaptyUIElementView(screen.content)
                        .frame(maxWidth: .infinity)
                        .padding(.top, p.safeAreaInsets.top)
                        .padding(.bottom, footerSize.height)
                }

                if let footer = screen.footer {
                    footerView(footer, globalProxy: p)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        footerSize = geometry.size
                                    }
                            }
                        )
                }

                if let overlay = screen.overlay {
                    AdaptyUIElementView(
                        overlay,
                        additionalPadding: p.safeAreaInsets
                    )
                }
            }
            .coordinateSpace(name: CoordinateSpace.adaptyBasicName)
            .ignoresSafeArea_fallback()
        }
    }
}

#if DEBUG

@available(iOS 13.0, *)
#Preview {
    AdaptyUIFlatContainerView(
        //        screen: .testFlatDog
        screen: .testTransparentScroll
//        screen: .testTransparent
    )
    .environmentObject(AdaptyUIActionResolver(logId: "preview"))
}
#endif

#endif
