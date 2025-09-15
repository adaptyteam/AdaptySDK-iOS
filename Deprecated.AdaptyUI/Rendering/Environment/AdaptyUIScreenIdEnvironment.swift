//
//  AdaptyUIScreenIdEnvironment.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIScreenIdKey: EnvironmentKey {
    static let defaultValue: String = "default"
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension EnvironmentValues {
    var adaptyScreenId: String {
        get { self[AdaptyUIScreenIdKey.self] }
        set { self[AdaptyUIScreenIdKey.self] = newValue }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    func withScreenId(_ value: String) -> some View {
        environment(\.adaptyScreenId, value)
    }
}

#endif
