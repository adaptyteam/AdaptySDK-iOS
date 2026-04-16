//
//  AdaptyUITransparentContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//

#if canImport(UIKit)

import SwiftUI

private enum ScrollAnchor {
    static let footerTop = "adapty.transparent.footer.top"
    static let footerBottom = "adapty.transparent.footer.bottom"
}

@MainActor
struct AdaptyUITransparentContainerView: View {
    var screen: VC.Screen

    @EnvironmentObject var stateViewModel: AdaptyUIStateViewModel
    @Environment(\.adaptyScreenInstance) var screenInstance: VS.ScreenInstance

    @State var footerSize: CGSize = .zero

    @ViewBuilder
    private func scrollableFooterView(
        _ element: VC.Element,
        globalProxy: GeometryProxy,
        scrollProxy: ScrollViewProxy
    ) -> some View {
        let additionalTopPadding = globalProxy.size.height
            - footerSize.height
            + globalProxy.safeAreaInsets.top
            + globalProxy.safeAreaInsets.bottom

        ScrollView {
            AdaptyUIElementView(
                element,
                screenHolderBuilder: { EmptyView() } // TODO: x check
            )
            .id(ScrollAnchor.footerTop)
            .onGeometrySizeChange { footerSize = $0 }
            .padding(.top, additionalTopPadding > 0.0 ? additionalTopPadding : nil)
            .keyboardBottomPadding()
            .scrollProgressTracker(kind: .footer, coordinateSpaceName: "adapty.container.transparent", viewportHeight: globalProxy.size.height)

            Color.clear.frame(height: 0).id(ScrollAnchor.footerBottom)
        }
        .scrollIndicatorsHidden_compatible()
        .scrollToFocusedField(using: scrollProxy, stateViewModel: stateViewModel)
        .onAppear {
            DispatchQueue.main.async {
                scrollProxy.scrollTo(ScrollAnchor.footerBottom, anchor: .bottom)
            }
        }
        .onChange(of: stateViewModel.scrollCommand) { command in
            guard let command, command.instanceId == screenInstance.id, command.kind == .footer else { return }
            withAnimation {
                scrollProxy.scrollTo(
                    command.value == .start ? ScrollAnchor.footerTop : ScrollAnchor.footerBottom,
                    anchor: command.value == .start ? .top : .bottom
                )
            }
        }
    }

    var body: some View {
        GeometryReader { p in
            ScrollViewReader { scrollProxy in
                ZStack(alignment: .bottom) {
                    AdaptyUIElementView(
                        screen.content,
                        screenHolderBuilder: { EmptyView() } // TODO: x check
                    )

                    if let footer = screen.footer {
                        scrollableFooterView(
                            footer,
                            globalProxy: p,
                            scrollProxy: scrollProxy
                        )
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
        .coordinateSpace(name: "adapty.container.transparent")
    }
}

#endif
