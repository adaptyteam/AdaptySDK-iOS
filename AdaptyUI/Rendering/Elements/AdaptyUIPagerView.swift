//
//  AdaptyUIPagerView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
extension AdaptyUI.VerticalAlignment {
    var swiftUIAlignment: Alignment {
        switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        case .justified: .center
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Pager.Length {
    func valueWith(parent: Double, screenSize: Double, safeAreaStart: Double, safeAreaEnd: Double) -> CGFloat {
        switch self {
        case let .fixed(unit): unit.points(screenSize: screenSize, safeAreaStart: safeAreaStart, safeAreaEnd: safeAreaEnd)
        case let .parent(value): parent * value
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.TransitionSlide {
    var swiftUIAnimation: Animation {
        switch interpolator {
        case .easeInOut: .easeInOut(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .linear: .linear(duration: duration)
        }
    }
}

@available(iOS 15.0, *)
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

@available(iOS 15.0, *)
struct AdaptyUIPagerView: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    
    var pager: AdaptyUI.Pager

    @State private var currentPage: Int = 0
    @State private var offset = CGFloat.zero
    @State private var isInteracting = false
    @State private var timer: Timer?

    init(_ pager: AdaptyUI.Pager) {
        self.pager = pager
    }

    @ViewBuilder
    private var viewportWithPageControl: some View {
        if let pageControl = pager.pageControl {
            switch pageControl.layout {
            case .overlaid:
                ZStack(alignment: pageControl.verticalAlignment.swiftUIAlignment) {
                    pagerView
                    pageControlView(pageControl)
                        .padding(pageControl.padding)
                }
            case .stacked:
                VStack(spacing: 0.0) {
                    switch pageControl.verticalAlignment {
                    case .top:
                        pageControlView(pageControl)
                            .padding(pageControl.padding)
                        pagerView
                    default:
                        pagerView
                        pageControlView(pageControl)
                            .padding(pageControl.padding)
                    }
                }
            }
        } else {
            pagerView
        }
    }

    var body: some View {
        viewportWithPageControl
            .onAppear {
                startAutoScroll()
            }
            .onDisappear {
                stopAutoScroll()
            }
    }

    // View for the Pager
    @ViewBuilder
    private var pagerView: some View {
        GeometryReader { proxy in
            let width = pager.pageWidth.valueWith(parent: proxy.size.width,
                                                  screenSize: screenSize.width,
                                                  safeAreaStart: safeArea.leading,
                                                  safeAreaEnd: safeArea.trailing)
                - pager.pagePadding.leading
                - pager.pagePadding.trailing

            let height = pager.pageHeight.valueWith(parent: proxy.size.height,
                                                    screenSize: screenSize.height,
                                                    safeAreaStart: safeArea.top,
                                                    safeAreaEnd: safeArea.bottom)
                - pager.pagePadding.top
                - pager.pagePadding.bottom

            let hPadding = (proxy.size.width - width) / 2.0

            HStack(spacing: pager.spacing) {
                ForEach(0 ..< pager.content.count, id: \.self) { idx in
                    AdaptyUIElementView(pager.content[idx])
                        .frame(width: width, height: height)
                        .padding(.leading, idx == 0 ? hPadding : 0)
                        .padding(.trailing, idx == pager.content.count - 1 ? hPadding : 0)
                }
            }
            .offset(x: CGFloat(-currentPage) * (width + pager.spacing) + offset)
            .animation(
                pager.animation?.pageTransition.swiftUIAnimation ?? .easeInOut,
                value: currentPage
            )
            .dragGesture(
                condition: pager.interactionBehaviour != .none,
                onChanged: { value in
                    offset = value.translation.width
                    isInteracting = true
                    stopAutoScroll() // Stop the autoscroll while interacting
                },
                onEnded: { value in
                    withAnimation(.easeOut) {
                        offset = value.predictedEndTranslation.width
                        currentPage -= Int((offset / width).rounded())
                        currentPage = max(0, min(currentPage, pager.content.count - 1))
                        offset = 0
                        isInteracting = false

                        if pager.interactionBehaviour == .pauseAnimation {
                            scheduleAutoScroll()
                        }
                    }
                }
            )
        }
    }

    @ViewBuilder
    private func pageControlView(_ pageControl: AdaptyUI.Pager.PageControl) -> some View {
        HStack(spacing: pageControl.spacing) {
            ForEach(0 ..< pager.content.count, id: \.self) { idx in
                Circle()
                    .fill(
                        idx == currentPage ?
                            pageControl.selectedColor.swiftuiColor :
                            pageControl.color.swiftuiColor
                    )
                    .frame(width: pageControl.dotSize,
                           height: pageControl.dotSize)
            }
        }
    }

    private func startAutoScroll() {
        guard let config = pager.animation else { return }

        stopAutoScroll()
        timer = Timer.scheduledTimer(withTimeInterval: config.startDelay, repeats: false) { _ in
            scheduleAutoScroll()
        }
    }

    private func scheduleAutoScroll() {
        guard let config = pager.animation else { return }

        timer = Timer.scheduledTimer(withTimeInterval: config.pageTransition.duration + config.pageTransition.startDelay, repeats: true) { _ in

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

    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}

#endif
