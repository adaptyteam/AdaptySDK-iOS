//
//  AdaptyUIBasicContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//
#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
extension CoordinateSpace {
    static let adaptyBasicName = "adapty.container.basic"
    static let adaptyBasic = CoordinateSpace.named(adaptyBasicName)
}

@available(iOS 15.0, *)
struct AdaptyUIBasicContainerView: View {
    var screen: AdaptyUI.Screen

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize

    @ViewBuilder
    func coverView(_ box: AdaptyUI.Box,
                   _ content: AdaptyUI.Element,
                   _ properties: AdaptyUI.Element.Properties?) -> some View
    {
        let height: CGFloat = {
            if let boxHeight = box.height, case let .fixed(unit) = boxHeight {
                return unit.points(screenSize: screenSize.height)
            } else {
                return 0.0
            }
        }()

        GeometryReader { p in
            let minY = p.frame(in: .adaptyBasic).minY
            let isScrollingDown = minY > 0
            let isScrollingUp = minY < 0

            AdaptyUIElementView(content)
                .frame(width : p.size.width,
                       height: isScrollingDown ? height + minY: height)
                .applyingProperties(properties)
                .clipped()
                .offset(
                    y: {
                        // TODO: inspect this behaviour
                        switch (isScrollingUp, isScrollingDown) {
                        case (false, true): -minY
                        case (true, false): -minY / 2.0
                        default: 0.0
                        }
                    }()
                )
        }
        .frame(height: height)
    }

    @State var footerSize: CGSize = .zero

    var body: some View {
        GeometryReader { p in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        if case let .box(box, properties) = screen.cover, let content = box.content {
                            coverView(box, content, properties)
                        }

                        AdaptyUIElementView(screen.content)
                    }
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
            .ignoresSafeArea()
        }
    }
}

#if DEBUG

@available(iOS 15.0, *)
#Preview {
    AdaptyUIBasicContainerView(
        screen: .testBasicDog
    )
    .environmentObject(AdaptyUIActionsViewModel(logId: "preview"))
}
#endif

#endif
