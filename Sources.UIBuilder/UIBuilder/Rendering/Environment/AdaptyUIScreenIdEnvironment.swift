//
//  AdaptyUIScreenIdEnvironment.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIScreenIdKey: EnvironmentKey {
    static let defaultValue: String = "default"
}

extension EnvironmentValues {
    var adaptyScreenId: String {
        get { self[AdaptyUIScreenIdKey.self] }
        set { self[AdaptyUIScreenIdKey.self] = newValue }
    }
}

extension View {
    func withScreenId(_ value: String) -> some View {
        environment(\.adaptyScreenId, value)
    }
}

#endif
