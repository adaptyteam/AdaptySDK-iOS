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
    static let adaptyFlatName = "adapty.container.flat"
    static let adaptyFlat = CoordinateSpace.named(adaptyFlatName)
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
                .preference(key: AdaptyUIGeometryFramePreferenceKey.self, value: proxy.frame(in: .adaptyFlat))
                .onPreferenceChange(AdaptyUIGeometryFramePreferenceKey.self) { onFrameChange($0) }
        }
        .frame(height: height)
    }
}

#endif
