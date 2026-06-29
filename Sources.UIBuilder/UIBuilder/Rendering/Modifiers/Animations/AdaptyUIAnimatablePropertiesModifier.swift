//
//  AdaptyUIAnimatablePropertiesModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import SwiftUI

// Tracks animation tokens with a class identity, so cleanup runs on real
// view destruction (StateObject deinit) — not on every temporary disappear
// (modal cover, app backgrounding) that .onDisappear conflates.
private final class AdaptyUIAnimationCoordinator: ObservableObject {
    var tokens: Set<AdaptyUIAnimationToken> = []

    deinit {
        let tokens = tokens
        Task { @MainActor in
            for token in tokens { token.invalidate() }
        }
    }
}

struct AdaptyUIAnimatablePropertiesModifier: ViewModifier {
    private var play: Binding<[VC.Animation]>

    private let initialBlurRadius: Double

    private let initialShadowFilling: VC.AssetReference?
    private let initialOffset: VC.Offset
    private let initialShadowOffset: VC.Offset
    private let initialShadowBlurRadius: Double

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel

    private let initialScaleX: CGFloat
    private let initialScaleY: CGFloat
    private let initialScaleAnchor: UnitPoint

    private let initialRotation: Angle
    private let initialRotationAnchor: UnitPoint

    private let initialOpacity: Double

    @State private var animatedScaleX: CGFloat?
    @State private var animatedScaleY: CGFloat?
    @State private var animatedScaleAnchor: UnitPoint?

    @State private var animatedRotation: Angle?
    @State private var animatedRotationAnchor: UnitPoint?

    @State private var animatedOpacity: Double?

    private var resolvedScaleX: CGFloat { animatedScaleX ?? initialScaleX }
    private var resolvedScaleY: CGFloat { animatedScaleY ?? initialScaleY }
    private var resolvedScaleAnchor: UnitPoint { animatedScaleAnchor ?? initialScaleAnchor }

    private var resolvedRotation: Angle { animatedRotation ?? initialRotation }
    private var resolvedRotationAnchor: UnitPoint { animatedRotationAnchor ?? initialRotationAnchor }

    private var resolvedOpacity: Double { animatedOpacity ?? initialOpacity }

    @State private var animatedBlurRadius: Double?

    @StateObject private var animationCoordinator = AdaptyUIAnimationCoordinator()

    init(
        _ properties: VC.Element.Properties,
        play: Binding<[VC.Animation]>
    ) {
        self.initialOpacity = properties.opacity

        self.initialScaleX = properties.scale?.scale.x ?? 1.0
        self.initialScaleY = properties.scale?.scale.y ?? 1.0
        self.initialScaleAnchor = properties.scale?.anchor.unitPoint ?? .center

        self.initialRotation = properties.rotation.map { .degrees($0.angle) } ?? .zero
        self.initialRotationAnchor = properties.rotation?.anchor.unitPoint ?? .center

        self.initialOffset = properties.offset ?? .zero

        self.initialBlurRadius = properties.decorator?.blurRadius ?? .zero

        self.initialShadowFilling = properties.decorator?.shadow?.filling
        self.initialShadowOffset = properties.decorator?.shadow?.offset ?? .zero
        self.initialShadowBlurRadius = properties.decorator?.shadow?.blurRadius ?? .zero

        self.play = play
    }

    init(
        play: Binding<[VC.Animation]>,
        initialOpacity: Double,
        initialScaleX: Double,
        initialScaleY: Double,
        initialScaleAnchor: UnitPoint,
        initialRotation: Angle,
        initialRotationAnchor: UnitPoint,
        initialOffset: VC.Offset,
        initialBlurRadius: Double,
        initialShadowFilling: VC.AssetReference?,
        initialShadowOffset: VC.Offset,
        initialShadowBlurRadius: Double,
    ) {
        self.initialOpacity = initialOpacity

        self.initialScaleX = initialScaleX
        self.initialScaleY = initialScaleY
        self.initialScaleAnchor = initialScaleAnchor

        self.initialRotation = initialRotation
        self.initialRotationAnchor = initialRotationAnchor

        self.initialOffset = initialOffset

        self.initialBlurRadius = initialBlurRadius

        self.initialShadowFilling = initialShadowFilling
        self.initialShadowOffset = initialShadowOffset
        self.initialShadowBlurRadius = initialShadowBlurRadius

        self.play = play
    }

    @State private var animatedOffsetX: CGFloat?
    @State private var animatedOffsetY: CGFloat?

    private var resolvedOffset: CGSize {
        CGSize(
            width: animatedOffsetX ?? initialOffset.x.points(.horizontal, screenSize, safeArea),
            height: animatedOffsetY ?? initialOffset.y.points(.vertical, screenSize, safeArea)
        )
    }

    private var resolvedBlurRadius: Double {
        animatedBlurRadius ?? initialBlurRadius
    }

    @State private var animatedShadowFilling: VC.AssetReference?
    @State private var animatedShadowBlurRadius: Double?
    @State private var animatedShadowOffset: CGSize?

    private var resolvedShadowFilling: VC.AssetReference? {
        animatedShadowFilling ?? initialShadowFilling
    }

    private var resolvedShadowBlurRadius: Double {
        animatedShadowBlurRadius ?? initialShadowBlurRadius
    }

    private var resolvedShadowOffset: CGSize {
        if let animatedShadowOffset {
            CGSize(
                width: animatedShadowOffset.width,
                height: animatedShadowOffset.height
            )
        } else {
            CGSize(
                width: initialShadowOffset.x.points(.horizontal, screenSize, safeArea),
                height: initialShadowOffset.y.points(.vertical, screenSize, safeArea)
            )
        }
    }

    func body(content: Content) -> some View {
        content
            .shadow(
                color: assetsViewModel.resolvedAsset(
                    resolvedShadowFilling,
                    mode: colorScheme.toVCMode,
                    screen: screen
                ).asColorAsset,
                blurRadius: resolvedShadowBlurRadius,
                offset: resolvedShadowOffset
            )
            .blur(radius: resolvedBlurRadius)
            .offset(resolvedOffset)
            .rotationEffect(resolvedRotation, anchor: resolvedRotationAnchor)
            .scaleEffect(x: resolvedScaleX, y: resolvedScaleY, anchor: resolvedScaleAnchor)
            .opacity(resolvedOpacity)
            .onChange(of: play.wrappedValue) { startAnimations($0) }
    }

    private func startAnimations(_ animations: [VC.Animation]) {
        var tokens = Set<AdaptyUIAnimationToken>()

        for animation in animations {
            let timeline = animation.timeline
            switch animation.kind {
            case let .opacity(value):
                animatedOpacity = value.start
                tokens.insert(
                    timeline.animate(
                        from: value.start,
                        to: value.end,
                        updateBlock: {
                            self.animatedOpacity = $0
                        }
                    )
                )
            case let .offset(value):
                animatedOffsetX = value.start.x.points(.horizontal, screenSize, safeArea)
                animatedOffsetY = value.start.y.points(.vertical, screenSize, safeArea)
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
            case let .rotation(value):
                animatedRotation = .degrees(value.angle.start)
                animatedRotationAnchor = value.anchor.unitPoint
                tokens.insert(
                    timeline.animate(
                        from: value.angle.start,
                        to: value.angle.end,
                        updateBlock: {
                            self.animatedRotation = .degrees($0)
                        }
                    )
                )
            case let .scale(value):
                animatedScaleX = value.scale.start.x
                animatedScaleY = value.scale.start.y
                animatedScaleAnchor = value.anchor.unitPoint

                tokens.insert(
                    timeline.animate(
                        from: value.scale.start,
                        to: value.scale.end,
                        updateBlock: {
                            self.animatedScaleX = $0.x
                            self.animatedScaleY = $0.y
                        }
                    )
                )
            case let .shadow(value):
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
            case let .blur(value):
                animatedBlurRadius = value.start
                tokens.insert(
                    timeline.animate(
                        from: value.start,
                        to: value.end,
                        updateBlock: {
                            self.animatedBlurRadius = $0
                        }
                    )
                )
            default:
                break
            }
        }

        animationCoordinator.tokens = tokens
    }
}

extension View {
    @ViewBuilder
    func animatableProperties(
        _ properties: VC.Element.Properties?,
        play: Binding<[VC.Animation]>
    ) -> some View {
        if let properties {
            modifier(
                AdaptyUIAnimatablePropertiesModifier(
                    properties,
                    play: play
                )
            )
        } else {
            self
        }
    }

    @ViewBuilder
    func animatablePropertiesTransition(
        play: Binding<[VC.Animation]>,
        initialOpacity: Double = 1.0,
        initialScaleX: Double = 1.0,
        initialScaleY: Double = 1.0,
        initialScaleAnchor: UnitPoint = .center,
        initialRotation: Angle = .zero,
        initialRotationAnchor: UnitPoint = .center,
        initialOffset: VC.Offset = .zero,
        initialBlurRadius: Double = .zero,
        initialShadowFilling: VC.AssetReference? = nil,
        initialShadowOffset: VC.Offset = .zero,
        initialShadowBlurRadius: Double = .zero,
    ) -> some View {
        modifier(
            AdaptyUIAnimatablePropertiesModifier(
                play: play,
                initialOpacity: initialOpacity,
                initialScaleX: initialScaleX,
                initialScaleY: initialScaleY,
                initialScaleAnchor: initialScaleAnchor,
                initialRotation: initialRotation,
                initialRotationAnchor: initialRotationAnchor,
                initialOffset: initialOffset,
                initialBlurRadius: initialBlurRadius,
                initialShadowFilling: initialShadowFilling,
                initialShadowOffset: initialShadowOffset,
                initialShadowBlurRadius: initialShadowBlurRadius,
            )
        )
    }
}

#endif
