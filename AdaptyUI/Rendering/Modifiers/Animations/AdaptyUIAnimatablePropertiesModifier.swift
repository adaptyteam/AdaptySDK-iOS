//
//  AdaptyUIAnimatablePropertiesModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
struct AdaptyUIAnimatablePropertiesModifier: ViewModifier {
    private let animations: [AdaptyViewConfiguration.Animation]

    private let initialShadowFilling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>?
    private let initialOffset: AdaptyViewConfiguration.Offset
    private let initialShadowOffset: AdaptyViewConfiguration.Offset
    private let initialShadowBlurRadius: Double

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    @State private var scaleX: CGFloat
    @State private var scaleY: CGFloat
    @State private var scaleAnchor: UnitPoint

    @State private var rotation: Angle
    @State private var rotationAnchor: UnitPoint

    @State private var opacity: Double
    
    @State private var animationTokens = Set<AdaptyUIAnimationToken>()

    init(_ properties: VC.Element.Properties) {
        self.opacity = properties.opacity ?? 1.0

        self.scaleX = 1.0
        self.scaleY = 1.0
        self.scaleAnchor = .center

        self.rotation = .zero
        self.rotationAnchor = .center

        self.initialOffset = properties.offset ?? .zero

        self.initialShadowFilling = properties.decorator?.shadow?.filling
        self.initialShadowOffset = properties.decorator?.shadow?.offset ?? .zero
        self.initialShadowBlurRadius = properties.decorator?.shadow?.blurRadius ?? .zero

        self.animations = properties.onAppear
    }

    @State private var animatedOffsetX: CGFloat?
    @State private var animatedOffsetY: CGFloat?

    private var resolvedOffset: CGSize {
        CGSize(
            width: animatedOffsetX ?? initialOffset.x.points(.horizontal, screenSize, safeArea) ?? 0.0,
            height: animatedOffsetY ?? initialOffset.y.points(.vertical, screenSize, safeArea) ?? 0.0
        )
    }

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
        content
            .shadow(
                filling: resolvedShadowFilling,
                blurRadius: resolvedShadowBlurRadius,
                offset: resolvedShadowOffset
            )
            .offset(resolvedOffset)
            .rotationEffect(rotation, anchor: rotationAnchor)
            .scaleEffect(x: scaleX, y: scaleY, anchor: scaleAnchor)
            .opacity(opacity)
            .onAppear { startAnimations() }
            .onDisappear {
                animationTokens.forEach { $0.invalidate() }
                animationTokens.removeAll()
            }
    }


    private func startAnimations() {
        var tokens = Set<AdaptyUIAnimationToken>()

        for animation in animations {
            switch animation {
            case let .opacity(timeline, value):
                startValueAnimation(
                    timeline,
                    from: value.start,
                    to: value.end
                ) { self.opacity = $0 }
            case let .offset(timeline, value):
                tokens.insert(
                    timeline.animate(
                        from: value.start,
                        to: value.end,
                        updateBlock: {
                            self.animatedOffsetX = $0.x.points(.horizontal, screenSize, safeArea)
                            self.animatedOffsetY = $0.y.points(.vertical, screenSize, safeArea)
                        }
                    )
                )
            case let .rotation(timeline, value):
                rotation = .degrees(value.angle.start)
                rotationAnchor = value.anchor.unitPoint
                startValueAnimation(
                    timeline,
                    from: value.angle.start,
                    to: value.angle.end
                ) { self.rotation = .degrees($0) }
            case let .scale(timeline, value):
                scaleX = value.scale.start.x
                scaleY = value.scale.start.y
                scaleAnchor = value.anchor.unitPoint
                startValueAnimation(
                    timeline,
                    from: value.scale.start,
                    to: value.scale.end
                ) {
                    self.scaleX = $0.x
                    self.scaleY = $0.y
                }
            case let .shadow(timeline, value):
                if let colorValue = value.color {
                    animatedShadowFilling = value.color?.start

                    startValueAnimation(
                        timeline,
                        from: colorValue.start,
                        to: colorValue.end
                    ) {
                        self.animatedShadowFilling = $0
                    }
                }

                if let blurValue = value.blurRadius {
                    animatedShadowBlurRadius = blurValue.start

                    startValueAnimation(
                        timeline,
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
                        timeline,
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

        animationTokens = tokens
    }

    @available(*, deprecated, renamed: "remove", message: "remove")
    private func startValueAnimation<Value>(
        _ timeline: AdaptyViewConfiguration.Animation.Timeline,
        from start: Value,
        to end: Value,
        updateBlock: (Value) -> Void
    ) {
        updateBlock(start)

        withAnimation(.custom(timeline: timeline, interpolator: timeline.interpolator)) {
            updateBlock(end)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func animatableProperties(_ properties: VC.Element.Properties?) -> some View {
        if let properties {
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *) {
                modifier(AdaptyUIAnimatablePropertiesModifier(properties))
            } else {
                modifier(AdaptyUIAnimatablePropertiesModifier_Fallback(properties))
            }
        } else {
            self
        }
    }
}

#endif
