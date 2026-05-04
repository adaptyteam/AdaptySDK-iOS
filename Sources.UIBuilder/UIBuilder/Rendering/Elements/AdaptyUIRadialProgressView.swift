//
//  AdaptyUIRadialProgressView.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 20.04.2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIRadialProgressArc: Shape {
    var startAngleDegrees: Double
    var sweepDegrees: Double
    let thickness: Double?
    let clockwise: Bool
    let roundedCaps: Bool

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngleDegrees, sweepDegrees) }
        set {
            startAngleDegrees = newValue.first
            sweepDegrees = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2.0
        let clampedSweep = max(0.0, min(sweepDegrees, 360.0))
        let endAngleDegrees = clockwise
            ? startAngleDegrees + clampedSweep
            : startAngleDegrees - clampedSweep

        var path = Path()

        guard clampedSweep > 0 else { return path }

        let start = Angle.degrees(startAngleDegrees)
        let end = Angle.degrees(endAngleDegrees)

        if let thickness, thickness > 0 {
            let innerRadius = max(0.0, outerRadius - thickness)

            path.addArc(
                center: center,
                radius: outerRadius,
                startAngle: start,
                endAngle: end,
                clockwise: !clockwise
            )

            path.addLine(
                to: CGPoint(
                    x: center.x + innerRadius * cos(endAngleDegrees * .pi / 180.0),
                    y: center.y + innerRadius * sin(endAngleDegrees * .pi / 180.0)
                )
            )

            path.addArc(
                center: center,
                radius: innerRadius,
                startAngle: end,
                endAngle: start,
                clockwise: clockwise
            )

            path.closeSubpath()

            if roundedCaps && clampedSweep < 360 {
                let midRadius = (outerRadius + innerRadius) / 2.0
                let capRadius = thickness / 2.0

                let startCenter = CGPoint(
                    x: center.x + midRadius * cos(startAngleDegrees * .pi / 180.0),
                    y: center.y + midRadius * sin(startAngleDegrees * .pi / 180.0)
                )
                path.addEllipse(in: CGRect(
                    x: startCenter.x - capRadius,
                    y: startCenter.y - capRadius,
                    width: thickness,
                    height: thickness
                ))

                let endCenter = CGPoint(
                    x: center.x + midRadius * cos(endAngleDegrees * .pi / 180.0),
                    y: center.y + midRadius * sin(endAngleDegrees * .pi / 180.0)
                )
                path.addEllipse(in: CGRect(
                    x: endCenter.x - capRadius,
                    y: endCenter.y - capRadius,
                    width: thickness,
                    height: thickness
                ))
            }
        } else {
            path.move(to: center)
            path.addArc(
                center: center,
                radius: outerRadius,
                startAngle: start,
                endAngle: end,
                clockwise: !clockwise
            )
            path.closeSubpath()
        }

        return path
    }
}

@MainActor
struct AdaptyUIRadialProgressView: View {
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel

    private let progress: VC.RadialProgress

    init(_ progress: VC.RadialProgress) {
        self.progress = progress
    }

    @State private var animatedValue: Double = 0.0

    private var resolvedAsset: AdaptyUIResolvedColorOrGradientOrImageAsset? {
        assetsViewModel.resolvedAsset(
            progress.asset,
            mode: colorScheme.toVCMode,
            screen: screen
        ).asColorOrGradientOrImageAsset
    }

    private var swiftUIAnimation: Animation {
        progress.transition.interpolator.createAnimation(
            duration: progress.transition.duration
        )
    }

    var body: some View {
        let targetValue = stateViewModel.getValue(progress.value, defaultValue: 0.0, screen: screen)
        let clampedValue = min(max(animatedValue, 0), 1)

        let arcShape = AdaptyUIRadialProgressArc(
            startAngleDegrees: progress.startAngle,
            sweepDegrees: progress.sweepAngle * clampedValue,
            thickness: progress.thickness,
            clockwise: progress.clockwise,
            roundedCaps: progress.roundedCaps
        )

        Group {
            if progress.clip {
                assetView
                    .mask(arcShape)
            } else {
                filledArc(arcShape)
            }
        }
        .animation(swiftUIAnimation, value: animatedValue)
        .onAppear {
            animatedValue = targetValue
        }
        .onChange(of: targetValue) { newValue in
            animatedValue = newValue
            fireActionsWhenTransitionEnds()
        }
    }

    private func fireActionsWhenTransitionEnds() {
        guard !progress.actions.isEmpty else { return }
        let totalDelay = progress.transition.startDelay + progress.transition.duration
        let actions = progress.actions
        let screen = screen
        if totalDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) { [weak stateViewModel] in
                stateViewModel?.execute(actions: actions, screen: screen)
            }
        } else {
            stateViewModel.execute(actions: actions, screen: screen)
        }
    }

    @ViewBuilder
    private var assetView: some View {
        switch resolvedAsset {
        case let .color(color):
            Rectangle().fillSolidColor(color)
        case let .colorGradient(gradient):
            Rectangle().fillColorGradient(gradient)
        case let .image(image):
            AdaptyUIImageView(
                .resolvedImageAsset(
                    asset: image,
                    aspect: .fill,
                    tint: nil
                )
            )
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private func filledArc(_ shape: AdaptyUIRadialProgressArc) -> some View {
        switch resolvedAsset {
        case let .color(color):
            shape.fill(color)
        case let .colorGradient(gradient):
            switch gradient {
            case let .linear(g): shape.fill(g)
            case let .angular(g): shape.fill(g)
            case let .radial(g): shape.fill(g)
            }
        case let .image(image):
            AdaptyUIImageView(
                .resolvedImageAsset(
                    asset: image,
                    aspect: .fill,
                    tint: nil
                )
            )
            .mask(shape)
        case .none:
            EmptyView()
        }
    }
}

#endif
