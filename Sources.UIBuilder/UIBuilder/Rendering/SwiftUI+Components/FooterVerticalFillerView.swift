//
//  FooterVerticalFillerView.swift
//
//
//  Created by Aleksey Goncharov on 25.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
extension CoordinateSpace {
    static let adaptyGlobalName = "adapty.container.global"
}

struct AdaptyUIGeometryFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct FooterVerticalFillerView: View {
    var height: Double
    var onFrameChange: (CGRect) -> Void

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .frame(height: height)
                .preference(key: AdaptyUIGeometryFramePreferenceKey.self, value: proxy.frame(in: .named(CoordinateSpace.adaptyGlobalName)))
                .onPreferenceChange(AdaptyUIGeometryFramePreferenceKey.self) { value in
                    Task { @MainActor in
                        onFrameChange(value)
                    }
                }
        }
        .frame(height: height)
    }
}

#endif
