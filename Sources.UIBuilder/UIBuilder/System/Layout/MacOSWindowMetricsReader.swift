//
//  MacOSWindowMetricsReader.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 20.02.2026.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package struct MacOSWindowMetricsReader: NSViewRepresentable {

    @Binding private var metrics: AdaptyUIWindowMetrics?

    package init(metrics: Binding<AdaptyUIWindowMetrics?>) {
        _metrics = metrics
    }

    package func makeCoordinator() -> Coordinator { .init(metrics: $metrics) }

    package func makeNSView(context: Context) -> WindowTrackingView {
        let view = WindowTrackingView()

        view.onWindowChanged = { [weak coordinator = context.coordinator] window in
            coordinator?.attach(window: window)
        }

        context.coordinator.attach(window: view.window)

        return view
    }

    package func updateNSView(_ nsView: WindowTrackingView, context: Context) {
        context.coordinator.attach(window: nsView.window)
    }

    package static func dismantleNSView(
        _ nsView: WindowTrackingView,
        coordinator: Coordinator
    ) {
        nsView.onWindowChanged = nil
        coordinator.cleanup()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension MacOSWindowMetricsReader {
    @MainActor
    package final class Coordinator: NSObject {
        private let metrics: Binding<AdaptyUIWindowMetrics?>
        private weak var window: NSWindow?
        private var frameObservation: NSKeyValueObservation?
        private var contentLayoutRectObservation: NSKeyValueObservation?

        fileprivate init(metrics: Binding<AdaptyUIWindowMetrics?>) {
            self.metrics = metrics
            super.init()
        }

        fileprivate func attach(window: NSWindow?) {
            guard self.window !== window else {
                if let window {
                    publish(window: window)
                }
                return
            }

            removeObservers()
            self.window = window

            guard let window else {
                metrics.wrappedValue = nil
                return
            }

            observeWindow(window)
            publish(window: window)
        }

        fileprivate func cleanup() {
            removeObservers()
            window = nil
        }

        private func observeWindow(_ window: NSWindow) {
            let names: [NSNotification.Name] = [
                NSWindow.didEnterFullScreenNotification,
                NSWindow.didExitFullScreenNotification,
                NSWindow.didChangeScreenNotification,
            ]

            for name in names {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(windowDidChange(_:)),
                    name: name,
                    object: window
                )
            }

            observeWindowLayoutChanges(window)
        }

        private func observeWindowLayoutChanges(_ window: NSWindow) {
            frameObservation = window.observe(\.frame, options: [.new]) { [weak self] window, _ in
                Task { @MainActor [weak self] in
                    self?.publish(window: window)
                }
            }

            contentLayoutRectObservation = window.observe(\.contentLayoutRect, options: [.new]) { [weak self] window, _ in
                Task { @MainActor [weak self] in
                    self?.publish(window: window)
                }
            }
        }

        @objc
        private func windowDidChange(_ notification: Notification) {
            guard
                let window = notification.object as? NSWindow,
                window === self.window
            else {
                return
            }

            publish(window: window)
        }

        private func publish(window: NSWindow) {
            guard window === self.window else {
                return
            }

            let nextMetrics = AdaptyUIWindowMetrics(
                safeAreaInsets: window.adaptySafeAreaInsets,
                windowSize: window.frame.size
            )

            guard metrics.wrappedValue != nextMetrics else {
                return
            }

            metrics.wrappedValue = nextMetrics
        }

        private func removeObservers() {
            NotificationCenter.default.removeObserver(self)
            frameObservation?.invalidate()
            frameObservation = nil
            contentLayoutRectObservation?.invalidate()
            contentLayoutRectObservation = nil
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package final class WindowTrackingView: NSView {
    var onWindowChanged: ((NSWindow?) -> Void)?

    override package func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        onWindowChanged?(window)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension NSWindow {
    var adaptySafeAreaInsets: EdgeInsets {
        let frameSize = frame.size
        let layoutRect = contentLayoutRect

        guard
            frameSize.width > 0,
            frameSize.height > 0,
            !layoutRect.isEmpty
        else { return EdgeInsets() }

        return .init(
            top: max(0, frameSize.height - layoutRect.maxY),
            leading: max(0, layoutRect.minX),
            bottom: max(0, layoutRect.minY),
            trailing: max(0, frameSize.width - layoutRect.maxX)
        )
    }
}

#endif
