//
//  SwiftUI+Placeholder.swift
//
//
//  Created by Aleksey Goncharov on 24.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func redactedAsPlaceholder(_ flag: Bool) -> some View {
        if #available(iOS 14.0, *), flag {
            redacted(reason: .placeholder)
        } else {
            self
        }
    }
}

#endif
