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
                   _ content: AdaptyUI.Element) -> some View
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

    @ViewBuilder
    func contentView(box: AdaptyUI.Box,
                     coverBox: AdaptyUI.Box,
                     content: AdaptyUI.Element,
                     properties: AdaptyUI.Element.Properties?,
                     additionalBottomPadding: Double) -> some View
    {
        let coverHeight: CGFloat = {
            if let boxHeight = coverBox.height, case let .fixed(unit) = boxHeight {
                return unit.points(screenSize: screenSize.height)
            } else {
                return 0.0
            }
        }()

        let selfHeight = screenSize.height - coverHeight
        let offsetY = properties?.offset.y ?? 0

        // TODO: refactor
        AdaptyUIElementView(content)
            .background(Color.blue)
            .padding(.bottom, additionalBottomPadding)
            .background(Color.brown)
            .frame(minHeight: selfHeight + additionalBottomPadding - offsetY + 120,
                   alignment: .top)
            .applyingProperties(properties)
            .padding(.bottom, -120)
    }

    @State var footerSize: CGSize = .zero

    var body: some View {
        GeometryReader { p in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        if let coverBox = screen.cover,
                           let coverContent = coverBox.content,
                           case let .box(contentBox, contentProperties) = screen.content, let contentContent = contentBox.content
                        {
                            coverView(coverBox,
                                      coverContent)

                            contentView(
                                box: contentBox,
                                coverBox: coverBox,
                                content: contentContent,
                                properties: contentProperties,
                                additionalBottomPadding: footerSize.height
                            )
                        }

//                        if  {
//                            contentView(box, content, properties, additionalBottomPadding: footerSize.height)
//                        }
                    }
//                    .padding(.bottom, footerSize.height)
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

#endif
