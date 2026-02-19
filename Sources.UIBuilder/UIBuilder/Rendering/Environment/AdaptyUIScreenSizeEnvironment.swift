//
//  AdaptyUIScreenSizeEnvironment.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .init(width: 320, height: 480)
}

struct AdaptyUIScreenInstanceKey: EnvironmentKey {
    static let defaultValue: VS.ScreenInstance = .init(
        id: "fake",
        navigatorId: "fake",
        configuration: .init(
            id: "fake",
            layoutBehaviour: .default,
            cover: nil,
            content: .unknown("fake", nil),
            footer: nil,
            screenActions: .empty
        ),
        contextPath: []
    )
}

extension EnvironmentValues {
    var adaptyScreenSize: CGSize {
        get { self[AdaptyUIScreenSizeKey.self] }
        set { self[AdaptyUIScreenSizeKey.self] = newValue }
    }

    var adaptyScreenInstance: VS.ScreenInstance {
        get { self[AdaptyUIScreenInstanceKey.self] }
        set { self[AdaptyUIScreenInstanceKey.self] = newValue }
    }
}

package extension View {
    func withScreenSize(_ value: CGSize) -> some View {
        environment(\.adaptyScreenSize, value)
    }

    func withScreenInstance(_ value: VS.ScreenInstance) -> some View {
        environment(\.adaptyScreenInstance, value)
    }
}

#endif
