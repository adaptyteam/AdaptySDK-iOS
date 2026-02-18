//
//  AdaptyUIScreenSizeEnvironment.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//


import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .init(width: 320, height: 480)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension EnvironmentValues {
    var adaptyScreenSize: CGSize {
        get { self[AdaptyUIScreenSizeKey.self] }
        set { self[AdaptyUIScreenSizeKey.self] = newValue }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension View {
    func withScreenSize(_ value: CGSize) -> some View {
        environment(\.adaptyScreenSize, value)
    }
}
