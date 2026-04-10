//
//  AdaptyUIFlatContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//

#if canImport(UIKit)

import SwiftUI

private enum ScrollAnchor {
    static let contentTop = "adapty.flat.content.top"
    static let contentBottom = "adapty.flat.content.bottom"
    static let footerTop = "adapty.flat.footer.top"
    static let footerBottom = "adapty.flat.footer.bottom"
}

@MainActor
struct AdaptyUIFlatContainerView: View {
    @State
    private var footerSize: CGSize = .zero
    @State
    private var drawFooterBackground = false

    @EnvironmentObject var stateViewModel: AdaptyUIStateViewModel
    @Environment(\.adaptyScreenInstance) var screenInstance: VS.ScreenInstance

    var screen: VC.Screen

    @ViewBuilder
    private func footerView(
        _ element: VC.Element,
        globalProxy: GeometryProxy,
        scrollProxy: ScrollViewProxy
    ) -> some View {
        if footerSize.height >= globalProxy.size.height {
            ScrollView {
                AdaptyUIElementView(
                    element,
                    screenHolderBuilder: { EmptyView() }, // TODO: x check
                    drawDecoratorBackground: drawFooterBackground
                )
                .id(ScrollAnchor.footerTop)
                .keyboardBottomPadding()
                .scrollProgressTracker(kind: .footer, coordinateSpaceName: CoordinateSpace.adaptyGlobalName, viewportHeight: globalProxy.size.height)

                Color.clear.frame(height: 0).id(ScrollAnchor.footerBottom)
            }
            .scrollIndicatorsHidden_compatible()
            .scrollToFocusedField(using: scrollProxy, stateViewModel: stateViewModel)
            .onChange(of: stateViewModel.scrollCommand) { command in
                guard let command, command.instanceId == screenInstance.id, command.kind == .footer else { return }
                withAnimation {
                    scrollProxy.scrollTo(
                        command.value == .start ? ScrollAnchor.footerTop : ScrollAnchor.footerBottom,
                        anchor: command.value == .start ? .top : .bottom
                    )
                }
            }
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
            ScrollViewReader { scrollProxy in
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack {
                            AdaptyUIElementView(
                                screen.content,
                                screenHolderBuilder: { EmptyView() } // TODO: x check
                            )
                            .id(ScrollAnchor.contentTop)
                            .frame(maxWidth: .infinity)

                            FooterVerticalFillerView(height: footerSize.height) { frame in
                                withAnimation {
                                    drawFooterBackground = frame.maxY > globalProxy.size.height + globalProxy.safeAreaInsets.bottom
                                }
                            }

                            Color.clear.frame(height: 0).id(ScrollAnchor.contentBottom)
                        }
                        .keyboardBottomPadding()
                        .scrollProgressTracker(kind: .main, coordinateSpaceName: CoordinateSpace.adaptyGlobalName, viewportHeight: globalProxy.size.height)
                    }
                    .scrollIndicatorsHidden_compatible()
                    .scrollToFocusedField(using: scrollProxy, stateViewModel: stateViewModel)
                    .onChange(of: stateViewModel.scrollCommand) { command in
                        guard let command, command.instanceId == screenInstance.id, command.kind == .content else { return }
                        withAnimation {
                            scrollProxy.scrollTo(
                                command.value == .start ? ScrollAnchor.contentTop : ScrollAnchor.contentBottom,
                                anchor: command.value == .start ? .top : .bottom
                            )
                        }
                    }

                    if let footer = screen.footer {
                        footerView(footer, globalProxy: globalProxy, scrollProxy: scrollProxy)
                            .onGeometrySizeChange { footerSize = $0 }
                    }

                }
                .ignoresSafeArea()
                .background {
                    if let background = screen.background {
                        AdaptyUIBackgroundElementsView(
                            backgrounds: background,
                            screenHolderBuilder: { EmptyView() } // TODO: x check
                        )
                    }
                }
                .overlay {
                    if let overlay = screen.overlay {
                        AdaptyUIOverlayElementsView(
                            overlays: overlay,
                            screenHolderBuilder: { EmptyView() } // TODO: x check
                        )
                    }
                }
            }
        }
        .coordinateSpace(name: CoordinateSpace.adaptyGlobalName)
    }
}

#endif
