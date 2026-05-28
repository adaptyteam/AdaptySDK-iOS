//
//  AdaptyUILinearProgressView.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 20.04.2026.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUILinearProgressView: View {
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel

    private let progress: VC.LinearProgress

    init(_ progress: VC.LinearProgress) {
        self.progress = progress
    }

    @State private var animatedValue: Double?

    private var isHorizontal: Bool {
        if case .horizontal = progress.orientation { return true }
        return false
    }

    private var alignment: Alignment {
        switch progress.orientation {
        case let .horizontal(h):
            switch h {
            case .leading: return .leading
            case .trailing: return .trailing
            case .left: return layoutDirection == .rightToLeft ? .trailing : .leading
            case .right: return layoutDirection == .rightToLeft ? .leading : .trailing
            case .center: return .center
            case .justified: return .leading
            }
        case let .vertical(v):
            switch v {
            case .top: return .top
            case .center: return .center
            case .bottom: return .bottom
            }
        }
    }

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

    private var maskAnchor: UnitPoint {
        switch progress.orientation {
        case let .horizontal(h):
            switch h {
            case .leading: return .leading
            case .trailing: return .trailing
            case .left: return layoutDirection == .rightToLeft ? .trailing : .leading
            case .right: return layoutDirection == .rightToLeft ? .leading : .trailing
            case .center: return .center
            case .justified: return .leading
            }
        case let .vertical(v):
            switch v {
            case .top: return .top
            case .center: return .center
            case .bottom: return .bottom
            }
        }
    }

    var body: some View {
        let targetValue = stateViewModel.getValue(progress.value, defaultValue: 0.0, screen: screen)
        let skip = progress.skipAnimationOnOverflow && progress.isOverflow(targetValue)
        let displayValue = animatedValue ?? progress.normalize(targetValue)

        Group {
            if progress.clip {
                assetView(aspect: progress.imageAspect)
                    .mask(
                        AdaptyUILinearProgressMaskShape(
                            progress: displayValue,
                            cornerRadius: progress.cornerRadius,
                            isHorizontal: isHorizontal,
                            anchor: maskAnchor
                        )
                        .fill(Color.black)
                    )
                    .compositingGroup()
            } else {
                GeometryReader { geometry in
                    let size = geometry.size
                    let w = isHorizontal ? size.width * displayValue : size.width
                    let h = isHorizontal ? size.height : size.height * displayValue

                    assetView(aspect: progress.imageAspect)
                        .applyingCornerRadius(progress.cornerRadius)
                        .frame(width: w, height: h)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: alignment
                        )
                }
            }
        }
        .onAppear {
            animatedValue = progress.normalize(targetValue)
        }
        .onChange(of: targetValue) { newValue in
            let normalised = progress.normalize(newValue)
            let skipNow = progress.skipAnimationOnOverflow && progress.isOverflow(newValue)
            if skipNow {
                var txn = Transaction()
                txn.disablesAnimations = true
                withTransaction(txn) { animatedValue = normalised }
            } else {
                withAnimation(swiftUIAnimation) { animatedValue = normalised }
            }
        }
        .fireProgressActions(
            actions: progress.actions,
            effectiveStartDelay: skip ? 0 : progress.transition.startDelay,
            effectiveDuration: skip ? 0 : progress.transition.duration,
            value: targetValue
        )
    }

    @ViewBuilder
    private func assetView(aspect: VC.AspectRatio) -> some View {
        switch resolvedAsset {
        case let .color(color):
            Rectangle().fillSolidColor(color)
        case let .colorGradient(gradient):
            Rectangle().fillColorGradient(gradient)
        case let .image(image):
            AdaptyUIImageView(
                .resolvedImageAsset(
                    asset: image,
                    aspect: aspect,
                    tint: nil
                )
            )
        case .none:
            EmptyView()
        }
    }
}

extension View {
    @ViewBuilder
    func applyingCornerRadius(_ corner: VC.CornerRadius) -> some View {
        if corner.isZero {
            self
        } else if corner.isSameRadius {
            clipShape(RoundedRectangle(cornerRadius: corner.topLeading))
        } else if #available(iOS 16.0, macOS 13.0, *) {
            clipShape(UnevenRoundedRectangle(cornerRadii: corner.systemRadii))
        } else {
            clipShape(UnevenRoundedRectangleFallback(cornerRadii: corner))
        }
    }
}

struct AdaptyUILinearProgressMaskShape: Shape {
    var progress: Double
    let cornerRadius: VC.CornerRadius
    let isHorizontal: Bool
    let anchor: UnitPoint

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let clamped = min(max(progress, 0), 1)
        let w = isHorizontal ? rect.width * clamped : rect.width
        let h = isHorizontal ? rect.height : rect.height * clamped

        guard w > 0, h > 0 else { return Path() }

        let x = isHorizontal ? (rect.width - w) * anchor.x : 0
        let y = !isHorizontal ? (rect.height - h) * anchor.y : 0
        let innerRect = CGRect(x: x, y: y, width: w, height: h)

        let maxR = min(w, h) / 2.0

        if cornerRadius.isSameRadius {
            let r = min(cornerRadius.topLeading, maxR)
            return Path(roundedRect: innerRect, cornerRadius: r)
        }

        let tl = min(cornerRadius.topLeading, maxR)
        let tr = min(cornerRadius.topTrailing, maxR)
        let br = min(cornerRadius.bottomTrailing, maxR)
        let bl = min(cornerRadius.bottomLeading, maxR)

        return Path { p in
            p.move(to: CGPoint(x: innerRect.minX + tl, y: innerRect.minY))
            p.addLine(to: CGPoint(x: innerRect.maxX - tr, y: innerRect.minY))
            p.addArc(
                center: CGPoint(x: innerRect.maxX - tr, y: innerRect.minY + tr),
                radius: tr,
                startAngle: .degrees(-90),
                endAngle: .zero,
                clockwise: false
            )
            p.addLine(to: CGPoint(x: innerRect.maxX, y: innerRect.maxY - br))
            p.addArc(
                center: CGPoint(x: innerRect.maxX - br, y: innerRect.maxY - br),
                radius: br,
                startAngle: .zero,
                endAngle: .degrees(90),
                clockwise: false
            )
            p.addLine(to: CGPoint(x: innerRect.minX + bl, y: innerRect.maxY))
            p.addArc(
                center: CGPoint(x: innerRect.minX + bl, y: innerRect.maxY - bl),
                radius: bl,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
            p.addLine(to: CGPoint(x: innerRect.minX, y: innerRect.minY + tl))
            p.addArc(
                center: CGPoint(x: innerRect.minX + tl, y: innerRect.minY + tl),
                radius: tl,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
            p.closeSubpath()
        }
    }
}

#endif
