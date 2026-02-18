//
//  AdaptyUIAnimatablePropertiesModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit) || canImport(AppKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAnimatablePropertiesModifier: ViewModifier {
    private let animations: [VC.Animation]

    private let initialShadowFilling: VC.Mode<VC.Filling>?
    private let initialOffset: VC.Offset
    private let initialShadowOffset: VC.Offset
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

    @State private var animatedShadowFilling: VC.Mode<VC.Filling>?
    @State private var animatedShadowBlurRadius: Double?
    @State private var animatedShadowOffset: CGSize?

    private var resolvedShadowFilling: VC.Mode<VC.Filling>? {
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
                tokens.insert(
                    timeline.animate(
                        from: value.start,
                        to: value.end,
                        updateBlock: {
                            self.opacity = $0
                        }
                    )
                )
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
                tokens.insert(
                    timeline.animate(
                        from: value.angle.start,
                        to: value.angle.end,
                        updateBlock: {
                            self.rotation = .degrees($0)
                        }
                    )
                )
            case let .scale(timeline, value):
                scaleX = value.scale.start.x
                scaleY = value.scale.start.y
                scaleAnchor = value.anchor.unitPoint

                tokens.insert(
                    timeline.animate(
                        from: value.scale.start,
                        to: value.scale.end,
                        updateBlock: {
                            self.scaleX = $0.x
                            self.scaleY = $0.y
                        }
                    )
                )
            case let .shadow(timeline, value):
                if let colorValue = value.color {
                    animatedShadowFilling = colorValue.start
                }

                if let blurValue = value.blurRadius {
                    animatedShadowBlurRadius = blurValue.start
                }

                if let offsetValue = value.offset {
                    animatedShadowOffset = CGSize(
                        width: offsetValue.start.x.points(.horizontal, screenSize, safeArea),
                        height: offsetValue.start.y.points(.vertical, screenSize, safeArea)
                    )
                }

                tokens.insert(
                    timeline.animate(
                        from: (value.color?.start, value.blurRadius?.start, value.offset?.start),
                        to: (value.color?.end, value.blurRadius?.end, value.offset?.end),
                        updateBlock: { value in
                            if let colorValue = value.0 {
                                animatedShadowFilling = colorValue
                            }

                            if let blurValue = value.1 {
                                animatedShadowBlurRadius = blurValue
                            }

                            if let offsetValue = value.2 {
                                animatedShadowOffset = CGSize(
                                    width: offsetValue.x.points(.horizontal, screenSize, safeArea),
                                    height: offsetValue.y.points(.vertical, screenSize, safeArea)
                                )
                            }
                        }
                    )
                )
            default:
                break
            }
        }

        animationTokens = tokens
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
