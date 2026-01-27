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
    static let defaultValue: VC.ScreenInstance = .init(
        id: "fake",
        type: "fake",
        contextPath: []
    )
}

extension EnvironmentValues {
    var adaptyScreenSize: CGSize {
        get { self[AdaptyUIScreenSizeKey.self] }
        set { self[AdaptyUIScreenSizeKey.self] = newValue }
    }
    
    var adaptyScreenInstance: VC.ScreenInstance {
        get { self[AdaptyUIScreenInstanceKey.self] }
        set { self[AdaptyUIScreenInstanceKey.self] = newValue }
    }
}

package extension View {
    func withScreenSize(_ value: CGSize) -> some View {
        environment(\.adaptyScreenSize, value)
    }
    
    func withScreenInstance(_ value: VC.ScreenInstance) -> some View {
        environment(\.adaptyScreenInstance, value)
    }
}

#endif
