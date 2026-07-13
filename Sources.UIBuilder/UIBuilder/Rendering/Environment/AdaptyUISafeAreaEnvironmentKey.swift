//
//  AdaptyUISafeAreaEnvironmentKey.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUISafeAreaEnvironmentKey: EnvironmentKey {
    static let defaultValue = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

extension EnvironmentValues {
    var adaptySafeAreaInsets: EdgeInsets {
        get { self[AdaptyUISafeAreaEnvironmentKey.self] }
        set { self[AdaptyUISafeAreaEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func withSafeArea(_ value: EdgeInsets) -> some View {
        environment(\.adaptySafeAreaInsets, value)
    }
}

#endif
