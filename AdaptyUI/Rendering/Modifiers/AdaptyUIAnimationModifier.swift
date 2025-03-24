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
struct AdaptyUIAnimatablePropertiesModifier: ViewModifier {
    private let animations: [AdaptyViewConfiguration.Animation]

    private let initialOffset: AdaptyViewConfiguration.Offset
    private let initialShadowOffset: AdaptyViewConfiguration.Offset

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

    @State private var shadowFilling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>?
    @State private var shadowBlurRadius: Double?

    init(_ properties: VC.Element.Properties) {
        self.opacity = properties.opacity ?? 1.0

        self.shadowFilling = properties.decorator?.shadow?.filling
        self.shadowBlurRadius = properties.decorator?.shadow?.blurRadius

        self.scaleX = 1.0
        self.scaleY = 1.0
        self.scaleAnchor = .center

        self.rotation = .zero
        self.rotationAnchor = .center

        self.initialOffset = properties.offset ?? .zero
        self.initialShadowOffset = properties.decorator?.shadow?.offset ?? .zero
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

    @State private var animatedShadowOffsetX: CGFloat?
    @State private var animatedShadowOffsetY: CGFloat?

    private var resolvedShadowOffset: CGSize {
        CGSize(
            width: animatedShadowOffsetX ?? initialShadowOffset.x.points(.horizontal, screenSize, safeArea) ?? 0.0,
            height: animatedShadowOffsetY ?? initialShadowOffset.y.points(.vertical, screenSize, safeArea) ?? 0.0
        )
    }

    func body(content: Content) -> some View {
        content
            .shadow(
                filling: shadowFilling,
                blurRadius: shadowBlurRadius,
                offset: resolvedShadowOffset
            )
            .offset(resolvedOffset)
            .rotationEffect(rotation, anchor: rotationAnchor)
            .scaleEffect(x: scaleX, y: scaleY, anchor: scaleAnchor)
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
            case let .offset(timeline, value):
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.animatedOffsetX = $0.x.points(.horizontal, screenSize, safeArea)
                    self.animatedOffsetY = $0.x.points(.vertical, screenSize, safeArea)
                }
            case let .rotation(timeline, value):
                rotationAnchor = value.anchor.unitPoint
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) { self.rotation = .degrees($0) }
            case let .scale(timeline, value):
                scaleAnchor = value.anchor.unitPoint
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.scaleX = $0.x
                    self.scaleY = $0.y
                }
            case let .shadow(timeline, value):
                shadowFilling = value.start
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.shadowFilling = $0
                }
            case let .shadowOffset(timeline, value):
                // TODO: add support for Y offset
                animatedShadowOffsetX = value.start.points(.horizontal, screenSize, safeArea)
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.animatedShadowOffsetX = $0.points(.horizontal, screenSize, safeArea)
                }
            case let .shadowBlurRadius(timeline, value):
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
