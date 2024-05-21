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

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize

    @State var footerSize: CGSize = .zero

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
                    AdaptyUIElementView(
                        footer,
                        additionalPadding: EdgeInsets(top: 0,
                                                      leading: 0,
                                                      bottom: p.safeAreaInsets.bottom,
                                                      trailing: 0)
                    )
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
        screen: .testFlatDog
    )
    .environmentObject(AdaptyUIActionResolver(logId: "preview"))
}
#endif

#endif
