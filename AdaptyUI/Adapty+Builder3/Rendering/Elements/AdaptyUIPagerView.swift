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
struct AdaptyPageControlConfiguration {
    enum Position {
        case none
        case outerTop(offset: CGFloat)
        case outerBottom(offset: CGFloat)
        case innerTop(offset: CGFloat)
        case innerBottom(offset: CGFloat)
    }

    var position: Position
    var dotSize: CGFloat
    var selectedColor: Color
    var unselectedColor: Color
}

@available(iOS 15.0, *)
struct AutoScrollConfiguration {
    var startDelay: TimeInterval
    var duration: TimeInterval
    var delay: TimeInterval
    var interpolator: Animation
    var repeatScroll: Bool
    var interruptionBehaviour: InterruptionBehaviour

    enum InterruptionBehaviour {
        case stop
        case `continue`
    }
}

@available(iOS 15.0, *)
struct AdaptyUIPagerView<PageContent: View>: View {
    enum PageSize {
        case fix(CGFloat)
        case padding(CGFloat)
        case fraction(CGFloat)

        func valueWith(total: CGFloat) -> CGFloat {
            switch self {
            case let .fix(value):
                return value
            case let .padding(value):
                return total - 2.0 * value
            case let .fraction(value):
                return total * value
            }
        }
    }

    var spacing: CGFloat
    var pageWidth: PageSize
    var pageHeight: PageSize
    var pageControlConfiguration: AdaptyPageControlConfiguration
    var autoScrollConfiguration: AutoScrollConfiguration?
    var userInteractionEnabled: Bool

    var itemsCount: Int
    var itemsBuilder: (Int) -> PageContent

    @State private var currentPage: Int = 0
    @State private var offset = CGFloat.zero
    @State private var isInteracting = false
    @State private var timer: Timer?

    init(
        spacing: CGFloat,
        pageWidth: PageSize,
        pageHeight: PageSize,
        pageControlConfiguration: AdaptyPageControlConfiguration,
        autoScrollConfiguration: AutoScrollConfiguration?,
        userInteractionEnabled: Bool,
        itemsCount: Int,
        @ViewBuilder itemsBuilder: @escaping (Int) -> PageContent
    ) {
        self.spacing = spacing
        self.pageWidth = pageWidth
        self.pageHeight = pageHeight
        self.pageControlConfiguration = pageControlConfiguration
        self.autoScrollConfiguration = autoScrollConfiguration
        self.userInteractionEnabled = userInteractionEnabled
        self.itemsCount = itemsCount
        self.itemsBuilder = itemsBuilder
    }

    var body: some View {
        VStack {
            switch pageControlConfiguration.position {
            case .none:
                pagerView
            case let .outerTop(offset):
                VStack(spacing: offset) {
                    pageControl
                    pagerView
                }
            case let .outerBottom(offset):
                VStack(spacing: offset) {
                    pagerView
                    pageControl
                }
            case let .innerTop(offset):
                ZStack(alignment: .top) {
                    pagerView
                    pageControl
                        .padding(.top, offset)
                }
            case let .innerBottom(offset):
                ZStack(alignment: .bottom) {
                    pagerView
                    pageControl
                        .padding(.bottom, offset)
                }
            }
        }
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
            let width = pageWidth.valueWith(total: proxy.size.width)
            let height = pageHeight.valueWith(total: proxy.size.height)
            let hPadding = (proxy.size.width - width) / 2.0

            LazyHStack(spacing: spacing) {
                ForEach(0 ..< itemsCount, id: \.self) { idx in
                    itemsBuilder(idx)
                        .frame(width: width, height: height)
                        .padding(.leading, idx == 0 ? hPadding : 0)
                        .padding(.trailing, idx == itemsCount - 1 ? hPadding : 0)
                }
            }
            .offset(x: CGFloat(-currentPage) * (width + spacing) + offset)
            .animation(autoScrollConfiguration?.interpolator ?? .linear, value: currentPage)
            .gesture(
                userInteractionEnabled ?
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.width
                        isInteracting = true
                        stopAutoScroll() // Stop the autoscroll while interacting
                    }
                    .onEnded { value in
                        withAnimation(.easeOut) {
                            offset = value.predictedEndTranslation.width
                            currentPage -= Int((offset / width).rounded())
                            currentPage = max(0, min(currentPage, itemsCount - 1))
                            offset = 0
                            isInteracting = false
                            if autoScrollConfiguration?.interruptionBehaviour == .continue {
                                scheduleAutoScroll()
                            }
                        }
                    }
                : nil
            )
        }
    }

    // View for the Page Control
    @ViewBuilder
    private var pageControl: some View {
        HStack {
            ForEach(0 ..< itemsCount, id: \.self) { idx in
                Circle()
                    .fill(idx == currentPage ? pageControlConfiguration.selectedColor : pageControlConfiguration.unselectedColor)
                    .frame(width: pageControlConfiguration.dotSize,
                           height: pageControlConfiguration.dotSize)
            }
        }
    }

    private func startAutoScroll() {
        guard let config = autoScrollConfiguration else { return }
        stopAutoScroll()
        timer = Timer.scheduledTimer(withTimeInterval: config.startDelay, repeats: false) { _ in
            scheduleAutoScroll()
        }
    }

    private func scheduleAutoScroll() {
        guard let config = autoScrollConfiguration else { return }
        timer = Timer.scheduledTimer(withTimeInterval: config.duration + config.delay, repeats: true) { _ in
            guard !isInteracting else { return }
            withAnimation(config.interpolator) {
                if currentPage < itemsCount - 1 {
                    currentPage += 1
                } else if config.repeatScroll {
                    currentPage = 0
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

#if DEBUG

@available(iOS 15.0, *)
#Preview {
    AdaptyUIPagerView(
        spacing: 24.0,
        pageWidth: .padding(40),
        pageHeight: .fraction(1.0),
        pageControlConfiguration: .init(
            position: .outerBottom(offset: 6.0),
            dotSize: 6.0,
            selectedColor: .blue,
            unselectedColor: .white
        ),
        autoScrollConfiguration: .init(
            startDelay: 3.0,
            duration: 0.3,
            delay: 1.0,
            interpolator: .easeInOut,
            repeatScroll: true,
            interruptionBehaviour: .continue
        ),
        userInteractionEnabled: true,
        itemsCount: 5
    ) { idx in
        Text("Index \(idx)")
            .font(.title)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    .background(Color.green)
    .frame(height: 300)
}

#endif

#endif
