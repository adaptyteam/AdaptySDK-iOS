//
//  SwiftUI+Placeholder.swift
//
//
//  Created by Aleksey Goncharov on 24.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func redactedAsPlaceholder(_ flag: Bool) -> some View {
        if flag {
            redacted(reason: .placeholder)
        } else {
            self
        }
    }
}

#endif
