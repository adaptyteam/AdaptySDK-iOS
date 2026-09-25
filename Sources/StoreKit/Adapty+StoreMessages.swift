//
//  Adapty+StoreMessages.swift
//  AdaptySDK
//

#if os(iOS) || os(visionOS)

import Foundation
import StoreKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private let log = Log.storeMessages

@available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
public extension Adapty {
    /// Returns the unique types of App Store messages currently waiting for manual presentation.
    ///
    /// This method does not wait for activation, display messages, or remove them. It returns an
    /// empty set when manual handling has not created a message manager.
    ///
    /// - Returns: A snapshot of pending message types.
    nonisolated static func getPendingStoreMessageTypes() async -> Set<AdaptyStoreMessageType> {
        await withOptionalSDK(methodName: .getPendingStoreMessageTypes) { sdk in
            guard let manager = sdk?.skMessageManager as? StoreKitMessageManager else {
                return []
            }
            return await manager.pendingTypes()
        }
    }

    #if canImport(UIKit)
    /// Displays the current pending App Store messages that match an optional type filter.
    ///
    /// The messages are processed sequentially. A successful system display call removes its
    /// message immediately; an individual display failure is logged and remains pending for retry.
    /// Passing `nil` for `filter` selects all current messages, including unknown future types.
    /// Passing `nil` for `scene` resolves a foreground-active scene before each display call.
    ///
    /// - Parameters:
    ///   - filter: The message types to display, or `nil` to display all current pending messages.
    ///   - scene: The exact window scene to use, or `nil` for best-effort scene resolution.
    /// - Throws: ``AdaptyError`` with `.operationInterrupted`, `.storeMessageSceneUnavailable`,
    ///   or `.storeMessageShowInProgress`.
    nonisolated static func showStoreMessages(
        for filter: Set<AdaptyStoreMessageType>? = nil,
        in scene: UIWindowScene? = nil
    ) async throws(AdaptyError) {
        if let scene {
            try await showStoreMessages(
                for: filter,
                route: .explicitScene
            ) { message in
                try message.display(in: scene)
            }
        } else {
            try await showStoreMessages(
                for: filter,
                route: .resolvedScene
            ) { message in
                guard let scene = resolveWindowScene() else {
                    throw StoreKitMessageManager.DisplayError.sceneUnavailable
                }
                try message.display(in: scene)
            }
        }
    }
    #endif

    /// Displays the current pending App Store messages through a SwiftUI presentation action.
    ///
    /// Passing `nil` for `filter` selects all current pending messages, including unknown future
    /// types. Individual action failures are logged, remain pending for retry, and do not fail the
    /// best-effort batch.
    ///
    /// - Parameters:
    ///   - filter: The message types to display, or `nil` to display all current pending messages.
    ///   - action: The action from `EnvironmentValues.displayStoreKitMessage` for the current view.
    /// - Throws: ``AdaptyError`` with `.operationInterrupted` or `.storeMessageShowInProgress`.
    @MainActor
    static func showStoreMessages(
        for filter: Set<AdaptyStoreMessageType>? = nil,
        using action: DisplayMessageAction
    ) async throws(AdaptyError) {
        try await showStoreMessages(
            for: filter,
            route: .swiftUIAction
        ) { message in
            try action(message)
        }
    }

    private enum PresentationRoute: String, Sendable {
        case explicitScene = "explicit_scene"
        case resolvedScene = "resolved_scene"
        case swiftUIAction = "swiftui_action"
    }

    private nonisolated static func showStoreMessages(
        for filter: Set<AdaptyStoreMessageType>?,
        route: PresentationRoute,
        display: @escaping StoreKitMessageManager.DisplayAction<StoreKit.Message>
    ) async throws(AdaptyError) {
        let logParams: EventParameters = [
            "route": route.rawValue,
            "types": filter?.map(\.rawValue).sorted() ?? "all",
        ]

        try await withOptionalSDK(methodName: .showStoreMessages, logParams: logParams) { sdk throws(AdaptyError) in
            guard let manager = sdk?.skMessageManager as? StoreKitMessageManager else {
                return
            }

            try await manager.show(
                matching: filter,
                display: display
            )
        }
    }
}

#if canImport(UIKit)
@MainActor
private func resolveWindowScene() -> UIWindowScene? {
    var firstActiveScene: UIWindowScene?

    for case let scene as UIWindowScene
    in UIApplication.shared.connectedScenes
        where scene.activationState == .foregroundActive
    {
        if scene.windows.contains(where: \.isKeyWindow) {
            return scene
        }

        if firstActiveScene == nil {
            firstActiveScene = scene
        }
    }

    return firstActiveScene
}
#endif

#endif
