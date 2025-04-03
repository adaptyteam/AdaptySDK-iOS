//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 23.05.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIGeometrySizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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
                        .onPreferenceChange(AdaptyUIGeometrySizePreferenceKey.self) { value in
                            Task { @MainActor in
                                onChange(value)
                            }
                        }
                }
            }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func onGeometrySizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
#if compiler(>=6.0)
        if #available(iOS 18.0, visionOS 2.0, *) {
            onGeometryChange(
                for: CGSize.self,
                of: { $0.frame(in: .global).size },
                action: { _, x in DispatchQueue.main.async { action(x) } }
            )
        } else {
            modifier(AdaptyUIGeometrySizeObserver(action))
        }
#else
        modifier(AdaptyUIGeometrySizeObserver(action))
#endif
    }
}

#endif
