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

    private func set(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            footerSize = proxy.size
        }

//        safeAreaInsets = geometry.safeAreaInsets
        return Color.clear
    }

    var body: some View {
        GeometryReader { p in
            ZStack(alignment: .bottom) {
                ScrollView {
                    Spacer().frame(height: p.safeAreaInsets.top)

                    AdaptyUIElementView(screen.content)
                        .padding(.bottom, footerSize.height)

                    Spacer().frame(height: p.safeAreaInsets.bottom)
                }

                if let footer = screen.footer {
                    AdaptyUIElementView(footer)
                        .background(GeometryReader(content: set(proxy:)))
                        .padding(.bottom, p.safeAreaInsets.bottom)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
//        .ignoresSafeArea()
    }
}

#if DEBUG

@testable import Adapty

@available(iOS 13.0, *)
#Preview {
    AdaptyUIFlatContainerView(
        screen: .init(
            background: .color(.testWhite),
            cover: nil,
            content: .stack(.testVStack, nil),
            footer: .stack(.testHStack, nil),
            overlay: nil
        )
    )
}

#endif

#endif
