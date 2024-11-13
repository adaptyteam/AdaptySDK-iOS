//
//  AdaptyUITransitionInModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Transition.Interpolator {
    func swiftuiAnimation(duration: Double) -> Animation {
        switch self {
        case .easeInOut: .easeInOut(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .linear: .linear(duration: duration)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Transition {
    var swiftuiAnimation: Animation? {
        switch self {
        case let .fade(params):
            params.interpolator
                .swiftuiAnimation(duration: params.duration)
                .delay(params.startDelay)
        case .unknown:
            nil
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUITransitionInModifier: ViewModifier {
    private let transitionIn: VC.Transition

    @State
    private var opacity: Double

    init(_ transitionIn: VC.Transition, _ visibility: Bool) {
        self.transitionIn = transitionIn
        opacity = visibility ? 1.0 : 0.0
    }

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(transitionIn.swiftuiAnimation) {
                    opacity = 1.0
                }
            }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func transitionIn(_ transitionIn: [VC.Transition]?, visibility: Bool) -> some View {
        if let transitionIn = transitionIn?.first {
            modifier(AdaptyUITransitionInModifier(transitionIn, visibility))
        } else {
            self
        }
    }
}

#endif
