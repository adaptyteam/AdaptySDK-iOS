//
//  AdaptyUIPagerView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import SwiftUI

extension VC.VerticalAlignment {
    var swiftUIAlignment: Alignment {
        switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        case .justified: .center
        }
    }
}

extension VC.Pager.Length {
    func valueWith(parent: Double, screenSize: Double, safeAreaStart: Double, safeAreaEnd: Double) -> CGFloat {
        switch self {
        case let .fixed(unit): unit.points(screenSize: screenSize, safeAreaStart: safeAreaStart, safeAreaEnd: safeAreaEnd)
        case let .parent(value): parent * value
        }
    }
}

extension VC.TransitionSlide {
    var swiftUIAnimation: Animation {
        interpolator.createAnimation(duration: duration)
    }
}

extension View {
    @ViewBuilder
    func dragGesture(condition: Bool,
                     onChanged: @escaping (DragGesture.Value) -> Void,
                     onEnded: @escaping (DragGesture.Value) -> Void) -> some View
    {
        if condition {
            gesture(
                DragGesture()
                    .onChanged { onChanged($0) }
                    .onEnded { onEnded($0) }
            )
        } else {
            self
        }
    }
}

fileprivate let pageControllTapAnimationDuration = 0.3

@MainActor
struct AdaptyUIPagerView<ScreenHolderContent: View>: View {

    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    private let pager: VC.Pager
    private let screenHolderBuilder: () -> ScreenHolderContent

    // We had to introduce this additional State variable to workaround weird SwiftUI crash caused animated currentPage change
    // PageControl now relies on currentPageSelectedIndex variable which is updating outside of withAnimation block
    @State private var currentPageSelectedIndex: Int = 0
    @State private var currentPage: Int = 0 {
        didSet {
            Task { @MainActor in
                currentPageSelectedIndex = currentPage
            }
        }
    }

    @State private var offset = CGFloat.zero
    @State private var isInteracting = false
    @State private var timer: Timer?

    init(
        _ pager: VC.Pager,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.pager = pager
        self.screenHolderBuilder = screenHolderBuilder
    }

    @ViewBuilder
    private func viewportWithPageControl(onPageDotTap: @escaping (Int) -> Void) -> some View {
        if let pageControl = pager.pageControl {
            switch pageControl.layout {
            case .overlaid:
                ZStack(alignment: pageControl.verticalAlignment.swiftUIAlignment) {
                    pagerView
                    pageControlView(pageControl, onDotTap: onPageDotTap)
                        .padding(pageControl.padding)
                }
            case .stacked:
                VStack(spacing: 0.0) {
                    switch pageControl.verticalAlignment {
                    case .top:
                        pageControlView(pageControl, onDotTap: onPageDotTap)
                            .padding(pageControl.padding)
                        pagerView
                    default:
                        pagerView
                        pageControlView(pageControl, onDotTap: onPageDotTap)
                            .padding(pageControl.padding)
                    }
                }
            }
        } else {
            pagerView
        }
    }

    var body: some View {
        viewportWithPageControl {
            handlePageControlTap(index: $0)
        }
        .onAppear {
            startAutoScroll()
        }
        .onDisappear {
            stopAutoScroll()
        }
    }

    private func handlePageControlTap(index: Int) {
        let shouldScheduleAutoscroll: Bool

        switch pager.interactionBehavior {
        case .none:
            shouldScheduleAutoscroll = false
            return
        case .cancelAnimation:
            shouldScheduleAutoscroll = false
            stopAutoScroll()
        case .pauseAnimation:
            shouldScheduleAutoscroll = true
            stopAutoScroll()
        }

        if pager.animation != nil {
            withAnimation(
                .easeInOut(
                    duration: pageControllTapAnimationDuration
                )
            ) {
                currentPage = index
            }
            if shouldScheduleAutoscroll {
                Task {
                    try await Task.sleep(seconds: pageControllTapAnimationDuration)
                    scheduleAutoScroll()
                }
            }
        } else {
            currentPage = index
            if shouldScheduleAutoscroll {
                scheduleAutoScroll()
            }
        }
    }

    // View for the Pager
    @ViewBuilder
    private var pagerView: some View {
        GeometryReader { proxy in
            let pagePaddingLeading = pager.pagePadding.leading.points(
                screenSize: screenSize.width,
                safeAreaStart: safeArea.leading,
                safeAreaEnd: safeArea.trailing
            )

            let pagePaddingTrailing = pager.pagePadding.trailing.points(
                screenSize: screenSize.width,
                safeAreaStart: safeArea.leading,
                safeAreaEnd: safeArea.trailing
            )

            let pagePaddingTop = pager.pagePadding.top.points(
                screenSize: screenSize.height,
                safeAreaStart: safeArea.top,
                safeAreaEnd: safeArea.bottom
            )

            let pagePaddingBottom = pager.pagePadding.bottom.points(
                screenSize: screenSize.height,
                safeAreaStart: safeArea.top,
                safeAreaEnd: safeArea.bottom
            )

            let width = pager.pageWidth.valueWith(parent: proxy.size.width,
                                                  screenSize: screenSize.width,
                                                  safeAreaStart: safeArea.leading,
                                                  safeAreaEnd: safeArea.trailing)
                - pagePaddingLeading
                - pagePaddingTrailing

            let height = pager.pageHeight.valueWith(parent: proxy.size.height,
                                                    screenSize: screenSize.height,
                                                    safeAreaStart: safeArea.top,
                                                    safeAreaEnd: safeArea.bottom)
                - pagePaddingTop
                - pagePaddingBottom

            let hPadding = (proxy.size.width - width) / 2.0
            let pages = pager.content
            HStack(spacing: pager.spacing) {
                ForEach(0 ..< pages.count, id: \.self) { idx in
                    AdaptyUIElementView(
                        pages[idx],
                        screenHolderBuilder: {
                            if idx == 0 {
                                screenHolderBuilder() // TODO: x check
                            } else {
                                EmptyView()
                            }
                        }
                    )
                    .frame(width: max(width, 0), height: max(height, 0))
                    .clipped()
                    .padding(.leading, idx == 0 ? hPadding : 0)
                    .padding(.trailing, idx == pages.count - 1 ? hPadding : 0)
                }
            }
            .offset(x: CGFloat(-currentPage) * (width + pager.spacing) + offset)
            .dragGesture(
                condition: pager.interactionBehavior != .none,
                onChanged: { value in
                    offset = value.translation.width * (layoutDirection == .leftToRight ? 1.0 : -1.0)
                    isInteracting = true
                    stopAutoScroll() // Stop the autoscroll while interacting
                },
                onEnded: { value in
                    withAnimation(pager.animation?.pageTransition.swiftUIAnimation ?? .easeInOut) {
                        offset = value.predictedEndTranslation.width * (layoutDirection == .leftToRight ? 1.0 : -1.0)
                        currentPage -= Int((offset / width).rounded())
                        currentPage = max(0, min(currentPage, pager.content.count - 1))
                        offset = 0
                        isInteracting = false

                        if pager.interactionBehavior == .pauseAnimation {
                            scheduleAutoScroll()
                        }
                    }
                }
            )
        }
    }

    @ViewBuilder
    private func pageControlView(
        _ pageControl: VC.Pager.PageControl,
        onDotTap: @escaping (Int) -> Void
    ) -> some View {
        HStack(spacing: pageControl.spacing) {
            ForEach(0 ..< pager.content.count, id: \.self) { idx in
                Circle()
                    .fill(
                        asset: assetsViewModel.resolvedAsset(
                            idx == currentPageSelectedIndex ? pageControl.selectedColor : pageControl.color,
                            mode: colorScheme.toVCMode,
                            screen: screen
                        ).asColorOrGradientOrImageAsset
                    )
                    .frame(width: pageControl.dotSize,
                           height: pageControl.dotSize)
                    .onTapGesture {
                        onDotTap(idx)
                    }
            }
        }
    }

    private func startAutoScroll() {
        guard let config = pager.animation else { return }

        stopAutoScroll()
        timer = Timer.scheduledTimer(
            withTimeInterval: config.startDelay,
            repeats: false
        ) { _ in
            Task { @MainActor in
                scheduleAutoScroll()
            }
        }
    }

    private func scheduleAutoScroll() {
        guard let config = pager.animation else { return }

        timer = Timer.scheduledTimer(
            withTimeInterval: config.pageTransition.duration + config.pageTransition.startDelay,
            repeats: true
        ) { _ in
            Task { @MainActor in
                guard !isInteracting else { return }

                if currentPage < pager.content.count - 1 {
                    withAnimation(config.pageTransition.swiftUIAnimation) {
                        currentPage += 1
                    }
                } else if let repeatTransition = config.repeatTransition {
                    withAnimation(repeatTransition.swiftUIAnimation) {
                        currentPage = 0
                    }
                } else {
                    stopAutoScroll()
                }
            }
        }
    }

    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}

#endif
