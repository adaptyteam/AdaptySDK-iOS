//
//  AdaptyUIAnimationModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Animation.Interpolator {
    func swiftuiAnimation(duration: Double) -> Animation {
        switch self {
        case .easeInOut: .easeInOut(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .linear: .linear(duration: duration)
        case let .cubicBezier(x1, y1, x2, y2):
            .easeInOut(duration: duration)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Animation {
    var swiftuiAnimation: Animation? {
        switch self {
        case let .opacity(params):
            params.interpolator
                .swiftuiAnimation(duration: params.duration)
                .delay(params.startDelay)
        case .unknown:
            nil
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAnimationModifier: ViewModifier {
    private let animation: VC.Animation

    @State
    private var opacity: Double

    init(_ animation: VC.Animation, _ opacity: Double) {
        self.animation = animation
        self.opacity = opacity
    }

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                if opacity < 1.0 {
                    withAnimation(animation.swiftuiAnimation) {
                        opacity = 1.0
                    }
                }
            }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func animations(_ animations: [VC.Animation]?, opacity: Double) -> some View {
        if let animation = animations?.first {
            modifier(AdaptyUIAnimationModifier(animation, opacity))
        } else {
            self
        }
    }
}

#endif
