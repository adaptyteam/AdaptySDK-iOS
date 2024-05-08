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
struct AdaptyUIFlatContainerView<CloseButton: View>: View {
    var screen: AdaptyUI.Screen

    var closeButtonBuilder: (() -> CloseButton)?

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
                if let mainBlock = screen.mainBlock {
                    ScrollView {
                        Spacer().frame(height: p.safeAreaInsets.top)

                        AdaptyUIElementView(mainBlock)
                            .padding(.bottom, footerSize.height)

                        Spacer().frame(height: p.safeAreaInsets.bottom)
                    }
                }

                if let footerBlock = screen.footerBlock {
                    AdaptyUIElementView(footerBlock)
                        .background(GeometryReader(content: set(proxy:)))
                        .padding(.bottom, p.safeAreaInsets.bottom)
                }

                if let closeButtonBuilder {
                    closeButtonBuilder()
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .topLeading)
                        .padding(.top, p.safeAreaInsets.top)
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
            mainImage: nil,
            mainBlock: .stack(.testVStack, nil),
            footerBlock: .stack(.testHStack, nil)
        ),
        closeButtonBuilder: {
            Button(action: {}, label: { Text("Dismiss") })
        }
    )
}

#endif

#endif
