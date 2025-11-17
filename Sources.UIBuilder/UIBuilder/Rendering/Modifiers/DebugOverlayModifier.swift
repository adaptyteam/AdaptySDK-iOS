//
//  DebugOverlayModifier.swift
//
//
//  Created by Aleksey Goncharov on 27.06.2024.
//

#if canImport(UIKit)

import SwiftUI

struct DebugOverlayEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var debugOverlayEnabled: Bool {
        get { self[DebugOverlayEnvironmentKey.self] }
        set { self[DebugOverlayEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func withDebugOverlayEnabled(_ value: Bool) -> some View {
        environment(\.debugOverlayEnabled, value)
    }
}

struct DebugOverlayModifier: ViewModifier {
    private static let debugOverlayColors: [Color] = [.red, .green, .blue, .brown, .teal, .purple, .pink, .orange]

    @Environment(\.debugOverlayEnabled)
    private var debugOverlayEnabled: Bool

    func body(content: Content) -> some View {
        if debugOverlayEnabled {
            content
                .overlay {
                    Rectangle()
                        .stroke(Self.debugOverlayColors.randomElement() ?? .red,
                                lineWidth: 1.0)
                }
        } else {
            content
        }
    }
}

#endif
