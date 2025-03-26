//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 3/24/25.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAnimatablePropertiesModifier_Fallback: ViewModifier {
    private let animations: [AdaptyViewConfiguration.Animation]
    private let initialShadowOffset: AdaptyViewConfiguration.Offset

    init(_ properties: VC.Element.Properties) {
        animations = properties.onAppear

        shadowFilling = properties.decorator?.shadow?.filling
        shadowBlurRadius = properties.decorator?.shadow?.blurRadius
        initialShadowOffset = properties.decorator?.shadow?.offset ?? .zero
    }

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    @State private var shadowFilling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>?
    @State private var shadowBlurRadius: Double?

    @State private var animatedShadowOffsetX: CGFloat?
    @State private var animatedShadowOffsetY: CGFloat?

    private var resolvedShadowOffset: CGSize {
        CGSize(
            width: animatedShadowOffsetX ?? initialShadowOffset.x.points(.horizontal, screenSize, safeArea) ?? 0.0,
            height: animatedShadowOffsetY ?? initialShadowOffset.y.points(.vertical, screenSize, safeArea) ?? 0.0
        )
    }

    func body(content: Content) -> some View {
        var result = AnyView(content)

        for animation in animations {
            switch animation {
            case .opacity, .offset, .rotation, .scale:
                result = AnyView(
                    result.modifier(
                        AdaptyUIAnimatableGeometryFallbackModifier(
                            animation: animation
                        )
                    )
                )
            default:
                continue
            }
        }

        return result
            .shadow(
                filling: shadowFilling,
                blurRadius: shadowBlurRadius,
                offset: resolvedShadowOffset
            )
            .onAppear { startAnimations() }
    }

    private func startAnimations() {
        for animation in animations {
            switch animation {
            case .shadow(let timeline, let value):
                shadowFilling = value.start
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.shadowFilling = $0
                }
            case .shadowOffset(let timeline, let value):
                animatedShadowOffsetX = value.start.x.points(.horizontal, screenSize, safeArea)
                animatedShadowOffsetY = value.start.y.points(.vertical, screenSize, safeArea)
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.animatedShadowOffsetX = $0.x.points(.horizontal, screenSize, safeArea)
                    self.animatedShadowOffsetY = $0.y.points(.vertical, screenSize, safeArea)
                }
            case .shadowBlurRadius(let timeline, let value):
                shadowBlurRadius = value.start
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.shadowBlurRadius = $0
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

        let (animation, _) = Animation.customFallback(
            timeline: timeline,
            interpolator: interpolator
        )

        withAnimation(animation) {
            updateBlock(end)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAnimatableGeometryFallbackModifier: ViewModifier {
    private let animation: AdaptyViewConfiguration.Animation
    private let swiftUIanimation: Animation
    private let functor: (Double) -> Double

    init(animation: AdaptyViewConfiguration.Animation) {
        self.animation = animation
        (swiftUIanimation, functor) = Animation.customFallback(animation: animation)
    }

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    @State private var progress = 0.0

    func body(content: Content) -> some View {
        bodyWithInterpolation(content: content)
            .onAppear {
                startAnimation(swiftUIanimation)
            }
    }

    @ViewBuilder
    private func bodyWithInterpolation(content: Content) -> some View {
        switch animation {
        case .opacity(let timeline, let value):
            content
                .valueInterpolator(progress, functor) {
                    $0.opacity(value.current(p: $1))
                }
        case .offset(let timeline, let value):
            content
                .valueInterpolator(progress, functor) {
                    $0.offset(
                        value.current(
                            p: $1,
                            screenSize,
                            safeArea
                        )
                    )
                }
        case .rotation(let timeline, let value):
            content
                .valueInterpolator(progress, functor) {
                    $0.rotationEffect(
                        value.currentRotation(p: $1),
                        anchor: value.anchor.unitPoint
                    )
                }
        case .scale(let timeline, let value):
            content
                .valueInterpolator(progress, functor) {
                    $0.scaleEffect(
                        value.current(p: $1),
                        anchor: value.anchor.unitPoint
                    )
                }
        default:
            content
        }
    }

    private func startAnimation(_ animation: Animation) {
        withAnimation(animation) {
            progress = 1.0
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyViewConfiguration.Animation.OffsetValue {
    func current(
        p: Double,
        _ screenSize: CGSize,
        _ safeArea: EdgeInsets
    ) -> CGSize {
        let startOffset = CGSize(
            width: start.x.points(.horizontal, screenSize, safeArea),
            height: start.y.points(.vertical, screenSize, safeArea)
        )

        let endOffset = CGSize(
            width: end.x.points(.horizontal, screenSize, safeArea),
            height: end.y.points(.vertical, screenSize, safeArea)
        )

        let xOffset = startOffset.width + (endOffset.width - startOffset.width) * p
        let yOffset = startOffset.height + (endOffset.height - startOffset.height) * p

        return CGSize(width: xOffset, height: yOffset)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyViewConfiguration.Animation.DoubleValue {
    func current(p: Double) -> Double {
        start + (end - start) * p
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyViewConfiguration.Animation.DoubleWithAnchorValue {
    func currentRotation(p: Double) -> Angle {
        .degrees(start) + (.degrees(end) - .degrees(start)) * p
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyViewConfiguration.Animation.PointWithAnchorValue {
    func current(p: Double) -> CGSize {
        CGSize(
            width: start.x + (end.x - start.x) * p,
            height: start.y + (end.y - start.y) * p
        )
    }
}

#endif
