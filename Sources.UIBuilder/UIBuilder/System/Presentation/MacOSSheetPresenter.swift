//
//  MacOSSheetPresenter.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 20.02.2026.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SwiftUI

@MainActor
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package final class MacOSSheetPresenter {
    private struct PendingPresentation {
        let parentWindow: NSWindow
        let sheetId: String
        let config: AdaptyMacOSSheetConfig
        let content: AnyView
    }

    private weak var parentWindow: NSWindow?
    private var activeSheetWindow: NSWindow?
    private var activeSheetId: String?
    private var activeConfig: AdaptyMacOSSheetConfig?
    private var pendingPresentation: PendingPresentation?

    private var keyMonitor: Any?
    private var parentWindowObservers = [NSObjectProtocol]()
    private var requestDismiss: ((String) -> Void)?
    private var requestedDismissSheetId: String?
    private var isProgrammaticDismiss = false

    package func sync(
        parentWindow: NSWindow?,
        sheetId: String?,
        config: AdaptyMacOSSheetConfig,
        content: AnyView?,
        onDismissRequest: @escaping (String) -> Void
    ) {
        requestDismiss = onDismissRequest

        guard
            let parentWindow,
            let sheetId,
            let content
        else {
            pendingPresentation = nil
            dismissActiveSheetIfNeeded()
            return
        }

        let switchedParentWindow = self.parentWindow !== parentWindow

        if switchedParentWindow {
            removeParentWindowObservers()
            self.parentWindow = parentWindow
            observeParentWindow(parentWindow)
        }

        if activeSheetId == sheetId,
           activeSheetWindow != nil,
           activeConfig == config,
           !switchedParentWindow {
            updateBorderlessSheetFrameForParentWindow()
            return
        }

        pendingPresentation = .init(
            parentWindow: parentWindow,
            sheetId: sheetId,
            config: config,
            content: content
        )

        if activeSheetWindow != nil {
            dismissActiveSheetIfNeeded()
        } else {
            presentPendingIfNeeded()
        }
    }

    package func cleanup() {
        pendingPresentation = nil
        requestDismiss = nil
        requestedDismissSheetId = nil
        removeParentWindowObservers()

        if let activeSheetWindow,
           let parentWindow {
            isProgrammaticDismiss = true
            parentWindow.endSheet(activeSheetWindow, returnCode: .cancel)
        } else {
            resetActiveState()
        }
    }

    package static func resolvedDismissPolicy(
        for config: AdaptyMacOSSheetConfig
    ) -> AdaptyMacOSSheetDismissPolicy {
        switch config.presentationType {
        case .borderlessCustom:
            return config.dismissPolicy
        case .titledSystemWindow:
            guard config.dismissPolicy.dismissableByOutsideClick else {
                return config.dismissPolicy
            }

            Log.ui.warn(
                "Outside-click dismiss is incompatible with .titledSystemWindow sheet semantics on native macOS. Falling back to outside-click disabled policy."
            )

            /// incompatible with .titledSystemWindow due native document-modal semantics.
            return .init(
                dismissableByOutsideClick: false,
                dismissableByEsc: config.dismissPolicy.dismissableByEsc,
                dismissableByCustomKeyboardShortcut: config.dismissPolicy.dismissableByCustomKeyboardShortcut
            )
        }
    }

    package static func shouldConsumeEscapeKey(
        dismissPolicy: AdaptyMacOSSheetDismissPolicy
    ) -> Bool {
        dismissPolicy.dismissableByEsc
    }

    private func presentPendingIfNeeded() {
        guard let pendingPresentation else { return }
        self.pendingPresentation = nil

        let resolvedDismissPolicy = Self.resolvedDismissPolicy(
            for: pendingPresentation.config
        )
        let resolvedConfig = AdaptyMacOSSheetConfig(
            presentationType: pendingPresentation.config.presentationType,
            dismissPolicy: resolvedDismissPolicy,
            windowType: pendingPresentation.config.windowType
        )

        let sheetWindow = makeSheetWindow(
            parentWindow: pendingPresentation.parentWindow,
            config: resolvedConfig,
            content: pendingPresentation.content
        )
        configureKeyboardMonitoring(
            for: pendingPresentation.sheetId,
            dismissPolicy: resolvedConfig.dismissPolicy
        )

        activeSheetWindow = sheetWindow
        activeSheetId = pendingPresentation.sheetId
        activeConfig = resolvedConfig

        pendingPresentation.parentWindow.beginSheet(sheetWindow) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleActiveSheetDidEnd()
            }
        }
    }

    private func dismissActiveSheetIfNeeded() {
        guard let parentWindow, let activeSheetWindow else {
            resetActiveState()
            presentPendingIfNeeded()
            return
        }

        isProgrammaticDismiss = true
        parentWindow.endSheet(activeSheetWindow, returnCode: .cancel)
    }

    private func handleActiveSheetDidEnd() {
        let dismissedSheetId = activeSheetId
        let shouldNotifyDismiss = !isProgrammaticDismiss

        isProgrammaticDismiss = false
        resetActiveState()

        if let dismissedSheetId,
           shouldNotifyDismiss {
            requestDismiss?(dismissedSheetId)
        }

        presentPendingIfNeeded()
    }

    private func resetActiveState() {
        activeSheetWindow = nil
        activeSheetId = nil
        activeConfig = nil
        requestedDismissSheetId = nil
        removeKeyMonitor()
    }

    private func makeSheetWindow(
        parentWindow: NSWindow,
        config: AdaptyMacOSSheetConfig,
        content: AnyView
    ) -> NSWindow {
        switch config.presentationType {
        case .borderlessCustom:
            let frame = borderlessSheetFrame(for: parentWindow)
            let window = NSWindow(
                contentRect: frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.isMovable = false
            window.level = .modalPanel
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true

            let hostingController = NSHostingController(
                rootView: BorderlessSheetContainerView(
                    content: content,
                    baseSize: config.windowType.baseSize,
                    dismissableByOutsideClick: config.dismissPolicy.dismissableByOutsideClick
                ) { [weak self] in
                    self?.requestDismissForCurrentSheet()
                }
            )
            window.contentViewController = hostingController
            return window

        case let .titledSystemWindow(title):
            let sheetSize = config.windowType.baseSize ?? defaultTitledSheetSize(for: parentWindow)
            var styleMask: NSWindow.StyleMask = [.titled]
            if config.windowType.resizable {
                styleMask.insert(.resizable)
            }

            let window = NSWindow(
                contentRect: NSRect(origin: .zero, size: sheetSize),
                styleMask: styleMask,
                backing: .buffered,
                defer: false
            )
            window.title = title
            window.level = .modalPanel
            window.isMovable = false

            let hostingController = NSHostingController(
                rootView: content
                    .frame(
                        minWidth: config.windowType.baseSize?.width,
                        minHeight: config.windowType.baseSize?.height
                    )
            )
            window.contentViewController = hostingController
            return window
        }
    }

    private func borderlessSheetFrame(for parentWindow: NSWindow) -> NSRect {
        let contentRect = parentWindow.contentLayoutRect
        let fallbackRect = parentWindow.contentView?.bounds ?? contentRect
        let resolvedRect = contentRect.isEmpty ? fallbackRect : contentRect
        let originInScreen = parentWindow.convertToScreen(NSRect(origin: resolvedRect.origin, size: .zero)).origin

        return NSRect(
            origin: originInScreen,
            size: resolvedRect.size
        )
    }

    private func defaultTitledSheetSize(for parentWindow: NSWindow) -> CGSize {
        let contentSize = parentWindow.contentLayoutRect.size

        guard contentSize.width > 0, contentSize.height > 0 else {
            return CGSize(width: 640, height: 520)
        }

        return CGSize(
            width: min(contentSize.width, 640),
            height: min(contentSize.height, 520)
        )
    }

    private func requestDismissForCurrentSheet() {
        guard let activeSheetId else { return }
        guard requestedDismissSheetId != activeSheetId else { return }

        requestedDismissSheetId = activeSheetId
        requestDismiss?(activeSheetId)
    }

    private func configureKeyboardMonitoring(
        for sheetId: String,
        dismissPolicy: AdaptyMacOSSheetDismissPolicy
    ) {
        removeKeyMonitor()

        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            guard self.activeSheetId == sheetId else { return event }

            if event.isEscapeKey {
                guard Self.shouldConsumeEscapeKey(dismissPolicy: dismissPolicy) else {
                    return event
                }

                self.requestDismissForCurrentSheet()
                return nil
            }

            if let shortcut = dismissPolicy.dismissableByCustomKeyboardShortcut,
               event.matches(shortcut: shortcut) {
                self.requestDismissForCurrentSheet()
                return nil
            }

            return event
        }
    }

    private func removeKeyMonitor() {
        guard let keyMonitor else { return }
        NSEvent.removeMonitor(keyMonitor)
        self.keyMonitor = nil
    }

    private func observeParentWindow(_ parentWindow: NSWindow) {
        let names: [NSNotification.Name] = [
            NSWindow.didResizeNotification,
            NSWindow.didEndLiveResizeNotification,
            NSWindow.didEnterFullScreenNotification,
            NSWindow.didExitFullScreenNotification,
            NSWindow.didChangeScreenNotification,
        ]

        for name in names {
            let observer = NotificationCenter.default.addObserver(
                forName: name,
                object: parentWindow,
                queue: nil
            ) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.updateBorderlessSheetFrameForParentWindow()
                }
            }
            parentWindowObservers.append(observer)
        }
    }

    private func removeParentWindowObservers() {
        for observer in parentWindowObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        parentWindowObservers.removeAll()
    }

    private func updateBorderlessSheetFrameForParentWindow() {
        guard
            let parentWindow,
            let activeSheetWindow,
            let activeConfig
        else { return }

        guard case .borderlessCustom = activeConfig.presentationType else { return }
        let frame = borderlessSheetFrame(for: parentWindow)
        activeSheetWindow.setFrame(frame, display: true)
    }
}

@MainActor
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private struct BorderlessSheetContainerView: View {
    let content: AnyView
    let baseSize: CGSize?
    let dismissableByOutsideClick: Bool
    let onOutsideTap: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    guard dismissableByOutsideClick else { return }
                    onOutsideTap()
                }

            content
                .frame(
                    width: baseSize?.width,
                    height: baseSize?.height
                )
                .fixedSize(horizontal: false, vertical: false)
                .clipShape(RoundedRectangle(cornerRadius: 16.0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension AdaptyMacOSSheetKeyboardModifiers {
    var eventModifierFlags: NSEvent.ModifierFlags {
        var result = NSEvent.ModifierFlags()

        if contains(.command) {
            result.insert(.command)
        }
        if contains(.option) {
            result.insert(.option)
        }
        if contains(.control) {
            result.insert(.control)
        }
        if contains(.shift) {
            result.insert(.shift)
        }

        return result
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension NSEvent {
    var isEscapeKey: Bool {
        if keyCode == 53 {
            return true
        }

        return charactersIgnoringModifiers == String(UnicodeScalar(27))
    }

    func matches(shortcut: AdaptyCustomKeyboardShortcut) -> Bool {
        let normalizedEventKey = (charactersIgnoringModifiers ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let normalizedShortcutKey = shortcut.key
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalizedShortcutKey.isEmpty else { return false }
        guard normalizedEventKey == normalizedShortcutKey else { return false }

        let eventModifiers = modifierFlags.intersection([.command, .option, .control, .shift])
        return eventModifiers == shortcut.modifiers.eventModifierFlags
    }
}

#endif
