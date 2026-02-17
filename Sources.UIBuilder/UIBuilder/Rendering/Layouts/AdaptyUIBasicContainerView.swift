//
//  AdaptyUIBasicContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//
#if canImport(UIKit)

import SwiftUI

extension CoordinateSpace {
    static let adaptyBasicName = "adapty.container.basic"
}

struct AdaptyUIBasicContainerView: View {
    @EnvironmentObject
    private var paywallViewModel: AdaptyUIPaywallViewModel
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @State
    private var footerSize: CGSize = .zero
    @State
    private var drawFooterBackground = false

    var screen: VC.Screen

    var body: some View {
        GeometryReader { globalProxy in
            ZStack(alignment: .bottom) {
                if let coverBox = screen.cover, let coverContent = coverBox.content {
                    ScrollView {
                        VStack(spacing: 0) {
                            coverView(
                                coverBox,
                                coverContent,
                                nil
                            )

                            contentView(
                                content: screen.content,
                                coverBox: coverBox,
                                globalProxy: globalProxy
                            )
                        }
                    }
                    .ignoresSafeArea()
                    .scrollIndicatorsHidden_compatible()
                } else {
                    Rectangle()
                        .hidden()
                        .onAppear {
                            paywallViewModel.reportDidFailRendering(
                                with: .wrongComponentType("screen.cover")
                            )
                        }
                }

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
            .coordinateSpace(name: CoordinateSpace.adaptyBasicName)
            .ignoresSafeArea()
        }
        .coordinateSpace(name: CoordinateSpace.adaptyGlobalName)
    }

    @ViewBuilder
    func coverView(
        _ box: VC.Box,
        _ content: VC.Element,
        _ properties: VC.Element.Properties?
    ) -> some View {
        let height: CGFloat = {
            if let boxHeight = box.height, case let .fixed(unit) = boxHeight {
                return unit.points(
                    screenSize: screenSize.height,
                    safeAreaStart: safeArea.top,
                    safeAreaEnd: safeArea.bottom
                )
            } else {
                return 0.0
            }
        }()

        GeometryReader { p in
            let minY = p.frame(in: .named(CoordinateSpace.adaptyBasicName)).minY
            let height = p.size.height
            let isScrollingDown = minY > 0
            let isScrollingUp = minY < 0
            let scale = height > 0.0 ? max(1.0, 1.0 + minY / height) : 1.0

            AdaptyUIElementView(
                content,
                screenHolderBuilder: { EmptyView() } // TODO: x check
            )
            .frame(
                width: p.size.width,
                height: {
                    if isScrollingDown {
                        return height + minY
                    } else {
                        return height
                    }
                }()
            )
            .scaleEffect(x: scale, y: scale, anchor: .center)
            .clipped()
            .offset(
                y: {
                    if isScrollingUp {
                        return -minY / 2.0
                    } else if isScrollingDown {
                        return -minY
                    } else {
                        return 0.0
                    }
                }()
            )
        }
        .frame(height: height)
    }
    
    
    @State
    private var playOnAppearAnimations: [VC.Animation] = []

    @ViewBuilder
    func contentView(
        content: VC.Element,
        coverBox: VC.Box,
        globalProxy: GeometryProxy
    ) -> some View {
        let bottomOverscrollHeight = screenSize.height
        let properties = content.properties
        let offsetY = properties?.offset.y.points(
            screenSize: screenSize.width,
            safeAreaStart: safeArea.leading,
            safeAreaEnd: safeArea.trailing
        ) ?? 0.0

        VStack(spacing: 0) {
            AdaptyUIElementWithoutPropertiesView(
                content,
                screenHolderBuilder: { EmptyView() } // TODO: x check
            )

            FooterVerticalFillerView(height: footerSize.height) { frame in
                withAnimation {
                    drawFooterBackground = frame.maxY > globalProxy.size.height + globalProxy.safeAreaInsets.bottom
                }
            }
        }
        .padding(.bottom, bottomOverscrollHeight - offsetY)
        .animatableDecorator(
            properties?.decorator,
            animations: properties?.onAppear,
            includeBackground: true
        )
        .animatableProperties(properties, play: $playOnAppearAnimations)
        .padding(properties?.padding)
        .padding(.bottom, offsetY - bottomOverscrollHeight)
        .onAppear {
            playOnAppearAnimations = properties?.onAppear ?? []
        }
    }

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
}

#endif
