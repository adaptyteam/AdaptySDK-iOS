//
//  AdaptyUIInterfaceOrientationEnvironment.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI
import UIKit

struct AdaptyUIInterfaceOrientationKey: EnvironmentKey {
    static let defaultValue: VC.Orientation = .portrait
}

extension EnvironmentValues {
    var adaptyInterfaceOrientation: VC.Orientation {
        get { self[AdaptyUIInterfaceOrientationKey.self] }
        set { self[AdaptyUIInterfaceOrientationKey.self] = newValue }
    }
}

extension VC.Orientation {
    /// Interface orientation of a specific window scene.
    /// Unlike `UIDevice.current.orientation`, it never reports `faceUp/unknown`.
    @MainActor
    static func of(_ scene: UIWindowScene?) -> VC.Orientation {
        switch scene?.interfaceOrientation {
        case .landscapeLeft, .landscapeRight: .landscape
        default: .portrait
        }
    }

    /// The active foreground window scene — fallback when a view is not yet
    /// attached to a specific window.
    @MainActor
    static var activeWindowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    /// Best-effort initial value used before the paywall is attached to its
    /// window. Platforms without a rotatable interface (Mac Catalyst, tvOS,
    /// visionOS) have no meaningful interface orientation, so they are fixed to
    /// `.landscape`; iOS/iPadOS read the active scene.
    @MainActor
    static var platformInitialGuess: VC.Orientation {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        of(activeWindowScene)
        #else
        .landscape
        #endif
    }
}

extension View {
    func withInterfaceOrientation(_ value: VC.Orientation) -> some View {
        environment(\.adaptyInterfaceOrientation, value)
    }
}

#endif
