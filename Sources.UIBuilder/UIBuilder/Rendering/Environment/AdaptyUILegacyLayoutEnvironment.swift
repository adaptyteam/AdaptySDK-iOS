//
//  AdaptyUILegacyLayoutEnvironment.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUILegacyLayoutEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// Forces the `GeometryReader`-based Row / Column / Flex / FlexStack / Switch
    /// views even where the `Layout`-based ones are available.
    var debugLegacyLayoutEnabled: Bool {
        get { self[AdaptyUILegacyLayoutEnvironmentKey.self] }
        set { self[AdaptyUILegacyLayoutEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Renders the adaptive containers through the pre-`Layout` implementation on
    /// every OS version, so the two paths can be compared side by side on one
    /// device.
    ///
    /// Deliberately **not** public: this is a developer tool, reachable only through
    /// `Dev_AdaptyUIRendererView(legacyLayout:)`, so it adds nothing to the SDK's
    /// public surface. Defaults to `false`, so production rendering is unaffected.
    func withLegacyLayoutEnabled(_ value: Bool) -> some View {
        environment(\.debugLegacyLayoutEnabled, value)
    }
}

#endif
