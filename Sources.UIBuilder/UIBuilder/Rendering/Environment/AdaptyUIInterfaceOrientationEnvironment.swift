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
    /// Real interface orientation of the active scene.
    /// Unlike `UIDevice.current.orientation`, it never reports `faceUp/unknown`.
    @MainActor
    static var currentInterface: VC.Orientation {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        switch scene?.interfaceOrientation {
        case .landscapeLeft, .landscapeRight: return .landscape
        default: return .portrait
        }
    }
}

extension View {
    func withInterfaceOrientation(_ value: VC.Orientation) -> some View {
        environment(\.adaptyInterfaceOrientation, value)
    }
}

#endif
