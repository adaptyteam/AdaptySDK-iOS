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

/// Calls `onFinished` once every animation started from one `play` value has
/// completed. `track()` is taken per animation, `seal()` after the last one.
@MainActor
private final class AdaptyUIAnimationCompletionGroup {
    private var pending = 0
    private var sealed = false
    private var onFinished: (() -> Void)?

    init(_ onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }

    func track() -> () -> Void {
        pending += 1
        return { [self] in
            pending -= 1
            fireIfDone()
        }
    }

    func seal() {
        sealed = true
        fireIfDone()
    }

    private func fireIfDone() {
        guard sealed, pending == 0, let onFinished else { return }
        self.onFinished = nil
        onFinished()
    }
}

struct AdaptyUIAnimatablePropertiesModifier: ViewModifier {
    private var play: Binding<[VC.Animation]>
    private let onFinished: (() -> Void)?

    private let initialBlurRadius: Double

    private let initialOffset: VC.Offset

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

        self.play = play
        self.onFinished = nil
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
        onFinished: (() -> Void)?
    ) {
        self.initialOpacity = initialOpacity

        self.initialScaleX = initialScaleX
        self.initialScaleY = initialScaleY
        self.initialScaleAnchor = initialScaleAnchor

        self.initialRotation = initialRotation
        self.initialRotationAnchor = initialRotationAnchor

        self.initialOffset = initialOffset

        self.initialBlurRadius = initialBlurRadius

        self.play = play
        self.onFinished = onFinished
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


    func body(content: Content) -> some View {
        content
            .blur(radius: resolvedBlurRadius)
            .offset(resolvedOffset)
            .rotationEffect(resolvedRotation, anchor: resolvedRotationAnchor)
            .scaleEffect(x: resolvedScaleX, y: resolvedScaleY, anchor: resolvedScaleAnchor)
            .opacity(resolvedOpacity)
            .onChange(of: play.wrappedValue) { startAnimations($0) }
    }

    private func startAnimations(_ animations: [VC.Animation]) {
        var tokens = Set<AdaptyUIAnimationToken>()
        // An empty `play` only resets the transition; it has nothing to finish.
        let completionGroup = animations.isEmpty ? nil : onFinished.map(AdaptyUIAnimationCompletionGroup.init)

        for animation in animations {
            let timeline = animation.timeline
            switch animation.kind {
            case let .opacity(value):
                animatedOpacity = value.start
                tokens.insert(
                    timeline.animate(
                        from: value.start,
                        to: value.end,
                        completion: completionGroup?.track(),
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
                        completion: completionGroup?.track(),
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
                        completion: completionGroup?.track(),
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
                        completion: completionGroup?.track(),
                        updateBlock: {
                            self.animatedScaleX = $0.x
                            self.animatedScaleY = $0.y
                        }
                    )
                )            case let .blur(value):
                animatedBlurRadius = value.start
                tokens.insert(
                    timeline.animate(
                        from: value.start,
                        to: value.end,
                        completion: completionGroup?.track(),
                        updateBlock: {
                            self.animatedBlurRadius = $0
                        }
                    )
                )
            default:
                break
            }
        }

        completionGroup?.seal()
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
        onFinished: (() -> Void)? = nil
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
                onFinished: onFinished
            )
        )
    }
}

#endif
