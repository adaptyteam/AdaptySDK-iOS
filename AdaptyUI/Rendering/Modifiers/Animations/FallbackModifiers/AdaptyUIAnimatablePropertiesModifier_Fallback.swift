//
//  AdaptyUIAnimatablePropertiesModifier_Fallback.swift
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

    private let initialShadowFilling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>?
    private let initialShadowOffset: AdaptyViewConfiguration.Offset
    private let initialShadowBlurRadius: Double

    init(_ properties: VC.Element.Properties) {
        animations = properties.onAppear

        initialShadowFilling = properties.decorator?.shadow?.filling
        initialShadowOffset = properties.decorator?.shadow?.offset ?? .zero
        initialShadowBlurRadius = properties.decorator?.shadow?.blurRadius ?? .zero
    }

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    @State private var animatedShadowFilling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>?
    @State private var animatedShadowBlurRadius: Double?
    @State private var animatedShadowOffset: CGSize?

    private var resolvedShadowFilling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>? {
        animatedShadowFilling ?? initialShadowFilling
    }

    private var resolvedShadowBlurRadius: Double {
        animatedShadowBlurRadius ?? initialShadowBlurRadius
    }

    private var resolvedShadowOffset: CGSize {
        CGSize(
            width: animatedShadowOffset?.width ?? initialShadowOffset.x.points(.horizontal, screenSize, safeArea) ?? 0.0,
            height: animatedShadowOffset?.height ?? initialShadowOffset.y.points(.vertical, screenSize, safeArea) ?? 0.0
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
                filling: resolvedShadowFilling,
                blurRadius: resolvedShadowBlurRadius,
                offset: resolvedShadowOffset
            )
            .onAppear { startAnimations() }
    }

    private func startAnimations() {
        for animation in animations {
            switch animation {
            case .shadow(_, let value):
                if let colorValue = value.color {
                    animatedShadowFilling = value.color?.start

                    startValueAnimation(
                        animation,
                        from: colorValue.start,
                        to: colorValue.end
                    ) {
                        self.animatedShadowFilling = $0
                    }
                }

                if let blurValue = value.blurRadius {
                    animatedShadowBlurRadius = blurValue.start

                    startValueAnimation(
                        animation,
                        from: blurValue.start,
                        to: blurValue.end
                    ) {
                        self.animatedShadowBlurRadius = $0
                    }
                }

                if let offsetValue = value.offset {
                    animatedShadowOffset = CGSize(
                        width: offsetValue.start.x.points(.horizontal, screenSize, safeArea),
                        height: offsetValue.start.y.points(.vertical, screenSize, safeArea)
                    )

                    startValueAnimation(
                        animation,
                        from: offsetValue.start,
                        to: offsetValue.end
                    ) {
                        animatedShadowOffset = CGSize(
                            width: $0.x.points(.horizontal, screenSize, safeArea),
                            height: $0.y.points(.vertical, screenSize, safeArea)
                        )
                    }
                }
            default:
                break
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension ViewModifier {
    func startValueAnimation<Value>(
        _ animation: AdaptyViewConfiguration.Animation,
        from start: Value,
        to end: Value,
        updateBlock: (Value) -> Void
    ) {
        updateBlock(start)

        let (animation, _) = Animation.customIgnoringElasticAndBounceBefore17(
            animation: animation,
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
        (swiftUIanimation, functor) = Animation.customIgnoringElasticAndBounceBefore17(animation: animation)
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
extension AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Offset> {
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
extension AdaptyViewConfiguration.Animation.Range<Double> {
    func current(p: Double) -> Double {
        start + (end - start) * p
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyViewConfiguration.Animation.RotationParameters {
    func currentRotation(p: Double) -> Angle {
        .degrees(angle.start) + (.degrees(angle.end) - .degrees(angle.start)) * p
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyViewConfiguration.Animation.ScaleParameters {
    func current(p: Double) -> CGSize {
        CGSize(
            width: scale.start.x + (scale.end.x - scale.start.x) * p,
            height: scale.start.y + (scale.end.y - scale.start.y) * p
        )
    }
}

#endif
