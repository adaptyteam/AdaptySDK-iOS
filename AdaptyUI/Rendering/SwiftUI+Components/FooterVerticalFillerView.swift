//
//  FooterVerticalFillerView.swift
//
//
//  Created by Aleksey Goncharov on 25.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, *)
extension CoordinateSpace {
    static let adaptyGlobalName = "adapty.container.global"
    static let adaptyGlobal = CoordinateSpace.named(adaptyGlobalName)
}

@available(iOS 15.0, *)
struct AdaptyUIGeometryFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

@available(iOS 15.0, *)
struct FooterVerticalFillerView: View {
    var height: Double
    var onFrameChange: (CGRect) -> Void

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .frame(height: height)
                .preference(key: AdaptyUIGeometryFramePreferenceKey.self, value: proxy.frame(in: .adaptyGlobal))
                .onPreferenceChange(AdaptyUIGeometryFramePreferenceKey.self) { onFrameChange($0) }
        }
        .frame(height: height)
    }
}

#endif
