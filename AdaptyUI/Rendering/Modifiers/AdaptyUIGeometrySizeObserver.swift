//
//  File.swift
//  
//
//  Created by Aleksey Goncharov on 23.05.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUIGeometrySizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

@available(iOS 15.0, *)
struct AdaptyUIGeometrySizeObserver: ViewModifier {
    var onChange: (CGSize) -> Void

    init(_ onChange: @escaping (CGSize) -> Void) {
        self.onChange = onChange
    }

    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    Color
                        .clear
                        .preference(key: AdaptyUIGeometrySizePreferenceKey.self, value: proxy.size)
                        .onPreferenceChange(AdaptyUIGeometrySizePreferenceKey.self) { onChange($0) }
                }
            }
    }
}

@available(iOS 15.0, *)
extension View {
    // TODO: use everywhere
    func onGeometrySizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        modifier(AdaptyUIGeometrySizeObserver(action))
    }
}

#endif
