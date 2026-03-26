//
//  ScrollProgressTracker.swift
//  AdaptyUIBuilder
//
//  Created by Adapty on 24.03.2026.
//

#if canImport(UIKit)

import SwiftUI

enum ScrollActionKind {
    case main
    case footer
}

private struct ScrollThrottleState {
    var lastFireTime: Date = .distantPast
    var lastFireProgress: Double = -1.0

    private static let minTimeInterval: TimeInterval = 0.1
    private static let minProgressDelta: Double = 0.01

    mutating func shouldFire(progress: Double) -> Bool {
        let progressDelta = abs(progress - lastFireProgress)
        guard progressDelta > 0 else { return false }

        // Always fire at boundaries (0.0 and 1.0) to guarantee
        // the UI reflects the final scroll position
        let atBoundary = progress <= 0.0 || progress >= 1.0

        let now = Date()
        let timeDelta = now.timeIntervalSince(lastFireTime)

        guard atBoundary || (timeDelta >= Self.minTimeInterval &&
              progressDelta >= Self.minProgressDelta) else {
            return false
        }

        lastFireTime = now
        lastFireProgress = progress
        return true
    }
}

@MainActor
private struct ScrollProgressTrackerModifier: ViewModifier {
    let kind: ScrollActionKind
    let scrollCoordinateSpaceName: String
    let viewportHeight: CGFloat

    @EnvironmentObject var stateViewModel: AdaptyUIStateViewModel
    @Environment(\.adaptyScreenInstance) var screen: VS.ScreenInstance

    @State private var throttleState = ScrollThrottleState()

    private var scrollVariable: VC.Variable? {
        switch kind {
        case .main:
            screen.configuration.contentScrollValue
        case .footer:
            screen.configuration.footerScrollValue
        }
    }

    func body(content: Content) -> some View {
        if scrollVariable != nil {
            trackedContent(content)
        } else {
            content
        }
    }

    @ViewBuilder
    private func trackedContent(_ content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .named(scrollCoordinateSpaceName))
                    let contentHeight = frame.height
                    let offset = -frame.minY
                    let scrollableHeight = contentHeight - viewportHeight
                    Color.clear
                        .onChange(of: frame.origin.y) { _ in
                            let currentFrame = proxy.frame(in: .named(scrollCoordinateSpaceName))
                            let currentOffset = -currentFrame.minY
                            let currentScrollable = currentFrame.height - viewportHeight
                            guard currentScrollable > 0 else { return }
                            let progress = min(max(currentOffset / currentScrollable, 0.0), 1.0)
                            handleProgressChange(progress)
                        }
                        .onAppear {
                            guard scrollableHeight > 0 else { return }
                            let progress = min(max(offset / scrollableHeight, 0.0), 1.0)
                            handleProgressChange(progress)
                        }
                }
            }
    }

    private func handleProgressChange(_ progress: Double) {
        guard throttleState.shouldFire(progress: progress),
              let variable = scrollVariable else { return }

        stateViewModel.setScrollProgress(
            progress,
            variable: variable,
            screen: screen
        )
    }
}

extension View {
    @ViewBuilder
    func scrollProgressTracker(
        kind: ScrollActionKind,
        coordinateSpaceName: String,
        viewportHeight: CGFloat
    ) -> some View {
        modifier(ScrollProgressTrackerModifier(
            kind: kind,
            scrollCoordinateSpaceName: coordinateSpaceName,
            viewportHeight: viewportHeight
        ))
    }
}

#endif
