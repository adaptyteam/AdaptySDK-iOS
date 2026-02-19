//
//  SwiftUI+SafeArea.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 20.02.2026.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func ignoresSafeAreaIf(_ shouldIgnore: Bool) -> some View {
        if shouldIgnore {
            ignoresSafeArea()
        } else {
            self
        }
    }
}
