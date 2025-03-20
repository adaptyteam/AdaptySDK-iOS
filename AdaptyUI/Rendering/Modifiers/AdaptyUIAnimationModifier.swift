//
//  AdaptyUIAnimationModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

extension Animation {
    static func fromInterpolator(
        _ interpolator: VC.Animation.Interpolator,
        duration: TimeInterval
    ) -> Animation {
        switch interpolator {
        case .easeInOut: .easeInOut(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .linear: .linear(duration: duration)
        case let .cubicBezier(x1, y1, x2, y2): .timingCurve(x1, y1, x2, y2)
        }
    }

    func withTimeline(_ timeline: AdaptyViewConfiguration.Animation.Timeline) -> Animation {
        guard let type = timeline.repeatType else { return self }

        switch type {
        case .reverse:
            if let count = timeline.repeatMaxCount {
                return delay(timeline.repeatDelay)
                    .repeatCount(count, autoreverses: true)
            } else {
                return delay(timeline.repeatDelay)
                    .repeatForever(autoreverses: true)
            }
        case .restart:
            if let count = timeline.repeatMaxCount {
                return delay(timeline.repeatDelay)
                    .repeatCount(count, autoreverses: false)
            } else {
                return delay(timeline.repeatDelay)
                    .repeatForever(autoreverses: false)
            }
        }
    }

    static func create(
        timeline: AdaptyViewConfiguration.Animation.Timeline,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator
    ) -> Animation {
        let result: Animation = .fromInterpolator(
            interpolator,
            duration: timeline.duration
        )
        .withTimeline(timeline)
        .delay(timeline.startDelay)

        return result
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAnimatablePropertiesModifier: ViewModifier {
    private let initialOffset: AdaptyViewConfiguration.Offset
    private let animations: [AdaptyViewConfiguration.Animation]

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    @State private var animatedOffsetX: CGFloat?
    @State private var animatedOffsetY: CGFloat?
    @State private var scaleX: CGFloat
    @State private var scaleY: CGFloat
    @State private var rotation: Angle
    @State private var opacity: Double

    init(_ properties: VC.Element.Properties) {
        self.scaleX = 1.0
        self.scaleY = 1.0
        self.rotation = .zero
        self.opacity = properties.opacity ?? 1.0

        self.initialOffset = properties.offset ?? .zero
        self.animations = properties.onAppear
    }
    
    private var resolvedOffset: CGSize {
        let resolvedX = animatedOffsetX ?? initialOffset.x.points(
            screenSize: self.screenSize.width,
            safeAreaStart: self.safeArea.leading,
            safeAreaEnd: self.safeArea.trailing
        )
        
        let resolvedY = animatedOffsetY ?? initialOffset.y.points(
            screenSize: self.screenSize.width,
            safeAreaStart: self.safeArea.leading,
            safeAreaEnd: self.safeArea.trailing
        )
        
        return CGSize(
            width: resolvedX ?? 0.0,
            height: resolvedY ?? 0.0
        )
    }

    func body(content: Content) -> some View {
        content
            .offset(resolvedOffset)
            .rotationEffect(rotation, anchor: .center)
            .scaleEffect(x: scaleX, y: scaleY, anchor: .center)
            .opacity(opacity)
            .onAppear { startAnimations() }
    }

    private func startAnimations() {
        for animation in animations {
            switch animation {
            case let .opacity(timeline, value):
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) { self.opacity = $0 }
            case let .offsetX(timeline, value):
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.animatedOffsetX = $0.points(
                        screenSize: self.screenSize.width,
                        safeAreaStart: self.safeArea.leading,
                        safeAreaEnd: self.safeArea.trailing
                    )
                }
            case let .offsetY(timeline, value):
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.animatedOffsetY = $0.points(
                        screenSize: self.screenSize.height,
                        safeAreaStart: self.safeArea.top,
                        safeAreaEnd: self.safeArea.bottom
                    )
                }
            case let .rotation(timeline, value):
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) { self.rotation = .degrees($0) }
            case let .scale(timeline, value):
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.scaleX = $0.x
                    self.scaleY = $0.y
                }
            default:
                break
            }
        }
    }

    private func startValueAnimation<Value>(
        _ timeline: AdaptyViewConfiguration.Animation.Timeline,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator,
        from start: Value,
        to end: Value,
        updateBlock: (Value) -> Void
    ) {
        updateBlock(start)

        withAnimation(.create(timeline: timeline, interpolator: interpolator)) {
            updateBlock(end)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func animatableProperties(_ properties: VC.Element.Properties?) -> some View {
        if let properties {
            modifier(AdaptyUIAnimatablePropertiesModifier(properties))
        } else {
            self
        }
    }
}

#endif
