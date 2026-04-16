//
//  AdaptyUIHeroContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//
#if canImport(UIKit)

import SwiftUI

extension CoordinateSpace {
    static let adaptyHeroName = "adapty.container.hero"
}

private enum ScrollAnchor {
    static let contentTop = "adapty.hero.content.top"
    static let contentBottom = "adapty.hero.content.bottom"
    static let footerTop = "adapty.hero.footer.top"
    static let footerBottom = "adapty.hero.footer.bottom"
}

struct AdaptyUIHeroContainerView: View {
    @EnvironmentObject
    private var flowViewModel: AdaptyUIFlowViewModel
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject
    private var eventBus: AdaptyUIEventBus
    @EnvironmentObject
    private var navigatorViewModel: AdaptyUINavigatorViewModel
    @Environment(\.adaptyScreenInstance)
    private var screenInstance: VS.ScreenInstance
    @Environment(\.adaptyScreenInstanceId)
    private var screenInstanceId: String?
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
            ScrollViewReader { scrollProxy in
                ZStack(alignment: .bottom) {
                    if let coverBox = screen.cover, let coverContent = coverBox.content {
                        ScrollView {
                            VStack(spacing: 0) {
                                coverView(
                                    coverBox,
                                    coverContent,
                                    nil
                                )
                                .id(ScrollAnchor.contentTop)

                                contentView(
                                    content: screen.content,
                                    coverBox: coverBox,
                                    globalProxy: globalProxy
                                )

                                Color.clear.frame(height: 0).id(ScrollAnchor.contentBottom)
                            }
                            .keyboardBottomPadding()
                            .scrollProgressTracker(
                                kind: .main,
                                coordinateSpaceName: CoordinateSpace.adaptyHeroName,
                                viewportHeight: globalProxy.size.height
                            )
                        }
                        .ignoresSafeArea()
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
                    } else {
                        Rectangle()
                            .hidden()
                            .onAppear {
                                flowViewModel.reportDidFailRendering(
                                    with: .wrongComponentType("screen.cover")
                                )
                            }
                    }

                    if let footer = screen.footer {
                        footerView(footer, globalProxy: globalProxy, scrollProxy: scrollProxy)
                            .onGeometrySizeChange { footerSize = $0 }
                    }

                }
                .coordinateSpace(name: CoordinateSpace.adaptyHeroName)
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
            let minY = p.frame(in: .named(CoordinateSpace.adaptyHeroName)).minY
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
    @State
    private var lastProcessedSequence: UInt = 0

    @ViewBuilder
    func contentView(
        content: VC.Element,
        coverBox: VC.Box,
        globalProxy: GeometryProxy
    ) -> some View {
        let bottomOverscrollHeight = screenSize.height
        let properties = content.properties
        let offsetY = properties?.offset?.y.points(
            screenSize: screenSize.width,
            safeAreaStart: safeArea.leading,
            safeAreaEnd: safeArea.trailing
        ) ?? 0.0

        VStack(spacing: 0) {
            AdaptyUIElementWithoutPropertiesView(
                content,
                playAnimations: $playOnAppearAnimations,
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
            play: $playOnAppearAnimations,
            includeBackground: true
        )
        .animatableProperties(properties, play: $playOnAppearAnimations)
        .padding(properties?.padding)
        .padding(.bottom, offsetY - bottomOverscrollHeight)
        .onAppear {
            consumeAndProcessPendingEvents(properties: properties)
        }
        .onChange(of: eventBus.revision) { _ in
            consumeAndProcessPendingEvents(properties: properties)
        }
    }

    private func consumeAndProcessPendingEvents(properties: VC.Element.Properties?) {
        guard let properties, properties.eventHandlers.isNotEmpty else { return }

        let pending = eventBus.consumePending(
            afterSequence: lastProcessedSequence,
            screenInstanceId: screenInstanceId,
            currentTopScreenInstanceId: navigatorViewModel.currentScreenInstanceIfSingle?.id
        )
        guard !pending.isEmpty else { return }

        for event in pending {
            for handler in properties.eventHandlers {
                guard handler.triggers.contains(where: { $0.events.contains(event.eventId) }) else { continue }
                if handler.animations.isNotEmpty {
                    if playOnAppearAnimations == handler.animations {
                        playOnAppearAnimations = []
                        DispatchQueue.main.async {
                            playOnAppearAnimations = handler.animations
                        }
                    } else {
                        playOnAppearAnimations = handler.animations
                    }
                }
            }
        }

        lastProcessedSequence = pending.last!.sequence
    }

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
                .scrollProgressTracker(kind: .footer, coordinateSpaceName: CoordinateSpace.adaptyHeroName, viewportHeight: globalProxy.size.height)

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
}

#endif
