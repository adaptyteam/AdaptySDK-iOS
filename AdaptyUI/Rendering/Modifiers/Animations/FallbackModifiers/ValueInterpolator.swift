//
//  ValueInterpolator.swift
//  Adapty
//
//  Created by Alexey Goncharov on 3/26/25.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIValueInterpolator<T>: AnimatableModifier where T: View {
    private var progress: Double
    private let functor: (Double) -> Double
    @ViewBuilder private let contentBuilder: (AnyView, Double) -> T

    init(
        progress: Double,
        functor: @escaping (Double) -> Double,
        @ViewBuilder contentBuilder: @escaping (AnyView, Double) -> T
    ) {
        self.progress = progress
        self.functor = functor
        self.contentBuilder = contentBuilder
    }

    nonisolated var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        contentBuilder(AnyView(content), functor(progress))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func valueInterpolator<T: View>(
        _ progress: Double,
        _ functor: @escaping (Double) -> Double,
        contentBuilder: @escaping (AnyView, Double) -> T
    ) -> some View {
        modifier(
            AdaptyUIValueInterpolator<T>(
                progress: progress,
                functor: functor,
                contentBuilder: contentBuilder
            )
        )
    }
}

#endif
