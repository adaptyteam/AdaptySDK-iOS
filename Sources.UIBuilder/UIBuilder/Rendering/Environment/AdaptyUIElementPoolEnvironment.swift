//
//  AdaptyUIElementPoolEnvironment.swift
//  AdaptyUIBuilder
//
#if canImport(UIKit)

import SwiftUI

struct AdaptyUIElementPoolKey: EnvironmentKey {
    static let defaultValue: [VC.Element] = []
}

extension EnvironmentValues {
    var adaptyElementPool: [VC.Element] {
        get { self[AdaptyUIElementPoolKey.self] }
        set { self[AdaptyUIElementPoolKey.self] = newValue }
    }
}

extension View {
    func withElementPool(_ value: [VC.Element]) -> some View {
        environment(\.adaptyElementPool, value)
    }
}

#endif
