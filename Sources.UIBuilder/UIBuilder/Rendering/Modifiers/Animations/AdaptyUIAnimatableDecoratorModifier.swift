//
//  AdaptyUIDecoratorModifier.swift
//
//
//  Created by Aleksey Goncharov on 24.05.2024.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
extension InsettableShape {
    @ViewBuilder
    func fillImage(
        _ image: AdaptyUIResolvedImageAsset,
        tint: AdaptyUIResolvedColorAsset?
    ) -> some View {
        self.background {
            AdaptyUIImageView(
                .resolvedImageAsset(
                    asset: image,
                    aspect: .fill,
                    tint: tint
                )
            )
        }
    }

    @ViewBuilder
    func fillSolidColor(
        _ color: AdaptyUIResolvedColorAsset
    ) -> some View {
        self.fill(color)
    }

    @ViewBuilder
    func fillColorGradient(
        _ gradient: AdaptyUIResolvedGradientAsset
    ) -> some View {
        switch gradient {
        case let .linear(gradient):
            self.fill(gradient)
        case let .angular(gradient):
            self.fill(gradient)
        case let .radial(gradient):
            self.fill(gradient)
        }
    }

    @ViewBuilder
    func fill(
        asset: AdaptyUIResolvedColorOrGradientOrImageAsset?
    ) -> some View {
        switch asset {
        case let .color(color):
            self.fillSolidColor(color)
        case let .colorGradient(colorGradient):
            self.fillColorGradient(colorGradient)
        case let .image(imageData):
            self.fillImage(imageData, tint: nil)
        case .none:
            self.fillSolidColor(.emptyAssetColor)
        }
    }
}

@MainActor
extension InsettableShape {
    @ViewBuilder
    private func strokeSolidColor(
        _ color: AdaptyUIResolvedColorAsset,
        lineWidth: CGFloat
    ) -> some View {
        self.strokeBorder(color, lineWidth: lineWidth)
    }

    @ViewBuilder
    private func strokeColorGradient(
        _ gradient: AdaptyUIResolvedGradientAsset,
        lineWidth: CGFloat
    ) -> some View {
        switch gradient {
        case let .linear(gradient):
            self.strokeBorder(gradient)
        case let .angular(gradient):
            self.strokeBorder(gradient)
        case let .radial(gradient):
            self.strokeBorder(gradient)
        }
    }

    @ViewBuilder
    func stroke(
        asset: AdaptyUIResolvedColorOrGradientAsset?,
        lineWidth: CGFloat
    ) -> some View {
        switch asset {
        case let .color(color):
            self.strokeSolidColor(color, lineWidth: lineWidth)
        case let .colorGradient(gradient):
            self.strokeColorGradient(gradient, lineWidth: lineWidth)
        case .none:
            self
        }
    }
}

extension View {
    @ViewBuilder
    func clipShape(_ shape: VC.ShapeType) -> some View {
        switch shape {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
                self.clipShape(UnevenRoundedRectangle(cornerRadii: radii.systemRadii))
            } else {
                self.clipShape(UnevenRoundedRectangleFallback(cornerRadii: radii))
            }
        case .circle:
            self.clipShape(Circle())
        case .curveUp:
            self.clipShape(CurveUpShape())
        case .curveDown:
            self.clipShape(CurveDownShape())
        }
    }
}

@MainActor
extension VC.ShapeType {
    @ViewBuilder
    func swiftUIShapeFill(
        asset: AdaptyUIResolvedColorOrGradientOrImageAsset?
    ) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .fill(asset: asset)
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .fill(asset: asset)
            }
        case .circle:
            Circle()
                .fill(asset: asset)
        case .curveUp:
            CurveUpShape()
                .fill(asset: asset)
        case .curveDown:
            CurveDownShape()
                .fill(asset: asset)
        }
    }

    @ViewBuilder
    func swiftUIShapeStroke(
        asset: AdaptyUIResolvedColorOrGradientAsset?,
        lineWidth: CGFloat
    ) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .stroke(asset: asset, lineWidth: lineWidth)
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .stroke(asset: asset, lineWidth: lineWidth)
            }
        case .circle:
            Circle()
                .stroke(asset: asset, lineWidth: lineWidth)
        case .curveUp:
            // Since there is no way to implement InsettableShape in a correct way, we make this hack with doubling the lineWidth
            CurveUpShape()
                .stroke(asset: asset, lineWidth: lineWidth * 2.0)
        case .curveDown:
            CurveDownShape()
                .stroke(asset: asset, lineWidth: lineWidth * 2.0)
        }
    }
}

@MainActor
@available(iOS 16.0, *)
extension InsettableShape {
    @ViewBuilder
    fileprivate func fill(
        asset: AdaptyUIResolvedColorOrGradientOrImageAsset?,
        innerShadow: ShadowStyle
    ) -> some View {
        switch asset {
        case let .color(color):
            self.fill(color.shadow(innerShadow))
        case let .colorGradient(gradient):
            switch gradient {
            case let .linear(g):
                self.fill(g.shadow(innerShadow))
            case let .angular(g):
                self.fill(g.shadow(innerShadow))
            case let .radial(g):
                self.fill(g.shadow(innerShadow))
            }
        case .image, .none:
            // Inner shadow on image backgrounds is not supported via ShapeStyle;
            // fall back to the regular fill so the image still renders.
            self.fill(asset: asset)
        }
    }
}

@MainActor
@available(iOS 16.0, *)
extension VC.ShapeType {
    @ViewBuilder
    func swiftUIShapeFill(
        asset: AdaptyUIResolvedColorOrGradientOrImageAsset?,
        innerShadow: ShadowStyle
    ) -> some View {
        switch self {
        case let .rectangle(radii):
            UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                .fill(asset: asset, innerShadow: innerShadow)
        case .circle:
            Circle().fill(asset: asset, innerShadow: innerShadow)
        case .curveUp:
            CurveUpShape().fill(asset: asset, innerShadow: innerShadow)
        case .curveDown:
            CurveDownShape().fill(asset: asset, innerShadow: innerShadow)
        }
    }
}

@MainActor
struct AdaptyUIAnimatableDecoratorModifier: ViewModifier {
    private let decorator: VC.Decorator
    private let includeBackground: Bool
    private var play: Binding<[VC.Animation]>

    @State private var animatedBackgroundFilling: VC.AssetReference?

    private var initialBorderFilling: VC.AssetReference?
    private var initialBorderThickness: Double?

    @State private var animatedBorderFilling: VC.AssetReference?
    @State private var animatedBorderThickness: Double?

    @State private var animationTokens = Set<AdaptyUIAnimationToken>()

    private var resolvedBorderFilling: VC.AssetReference? {
        self.animatedBorderFilling ?? self.initialBorderFilling
    }

    private var resolvedBorderThickness: Double? {
        self.animatedBorderThickness ?? self.initialBorderThickness
    }

    private let initialInnerShadowFilling: VC.AssetReference?
    private let initialInnerShadowBlurRadius: Double
    private let initialInnerShadowOffset: VC.Offset

    @State private var animatedInnerShadowFilling: VC.AssetReference?
    @State private var animatedInnerShadowBlurRadius: Double?
    @State private var animatedInnerShadowOffset: CGSize?

    private var resolvedInnerShadowFilling: VC.AssetReference? {
        animatedInnerShadowFilling ?? initialInnerShadowFilling
    }

    private var resolvedInnerShadowBlurRadius: Double {
        animatedInnerShadowBlurRadius ?? initialInnerShadowBlurRadius
    }

    private var resolvedInnerShadowOffset: CGSize {
        if let animatedInnerShadowOffset {
            animatedInnerShadowOffset
        } else {
            CGSize(
                width: initialInnerShadowOffset.x.points(.horizontal, screenSize, safeArea),
                height: initialInnerShadowOffset.y.points(.vertical, screenSize, safeArea)
            )
        }
    }

    init(
        decorator: VC.Decorator,
        play: Binding<[VC.Animation]>,
        includeBackground: Bool
    ) {
        self.decorator = decorator
        self.play = play
        self.includeBackground = includeBackground

        self.initialBorderFilling = decorator.border?.filling
        self.initialBorderThickness = decorator.border?.thickness

        self.initialInnerShadowFilling   = decorator.innerShadow?.filling
        self.initialInnerShadowBlurRadius = decorator.innerShadow?.blurRadius ?? .zero
        self.initialInnerShadowOffset     = decorator.innerShadow?.offset ?? .zero
    }

    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        self.bodyWithBackground(
            content: content
        )
        .overlay {
            if let borderFilling = resolvedBorderFilling, let borderThickness = resolvedBorderThickness {
                self.decorator.shapeType
                    .swiftUIShapeStroke(
                        asset: self.assetsViewModel.resolvedAsset(
                            borderFilling,
                            mode: self.colorScheme.toVCMode,
                            screen: screen
                        ).asColorOrGradientAsset,
                        lineWidth: borderThickness
                    )
            }
        }
        .clipShape(self.decorator.shapeType)
        .onChange(of: play.wrappedValue) { self.startAnimations($0) }
        .onDisappear {
            self.animationTokens.forEach { $0.invalidate() }
            self.animationTokens.removeAll()
        }
    }

    @ViewBuilder
    private func bodyWithBackground(content: Content) -> some View {
        if let animatedBackgroundFilling {
            content
                .background {
                    self.backgroundFill(for: animatedBackgroundFilling)
                        .opacity(includeBackground ? 1.0 : 0.0)
                }
        } else if let background = self.decorator.background {
            content
                .background {
                    self.backgroundFill(for: background)
                }
        } else {
            content
        }
    }

    @ViewBuilder
    private func backgroundFill(for filling: VC.AssetReference) -> some View {
        let asset = self.assetsViewModel.resolvedAsset(
            filling,
            mode: self.colorScheme.toVCMode,
            screen: screen
        ).asColorOrGradientOrImageAsset

        if #available(iOS 16.0, *), let innerShadow = resolvedInnerShadowStyle {
            self.decorator.shapeType
                .swiftUIShapeFill(asset: asset, innerShadow: innerShadow)
        } else {
            self.decorator.shapeType
                .swiftUIShapeFill(asset: asset)
        }
    }

    @available(iOS 16.0, *)
    private var resolvedInnerShadowStyle: ShadowStyle? {
        guard let filling = resolvedInnerShadowFilling else { return nil }
        let color = self.assetsViewModel.resolvedAsset(
            filling,
            mode: self.colorScheme.toVCMode,
            screen: screen
        ).asColorAsset
        return .inner(
            color: color ?? .clear,
            radius: resolvedInnerShadowBlurRadius,
            x: resolvedInnerShadowOffset.width,
            y: resolvedInnerShadowOffset.height
        )
    }

    private func startAnimations(_ animations: [VC.Animation]) {
        guard !animations.isEmpty else { return }

        var tokens = Set<AdaptyUIAnimationToken>()

        for animation in animations {
            switch animation {
            case let .background(timeline, value):
                self.animatedBackgroundFilling = value.start

                tokens.insert(
                    timeline.animate(
                        from: value.start,
                        to: value.end,
                        updateBlock: { self.animatedBackgroundFilling = $0 }
                    )
                )
            case let .border(timeline, value):
                self.animatedBorderThickness = value.thickness?.start

                if let color = value.color {
                    self.animatedBorderFilling = value.color?.start

                    tokens.insert(
                        timeline.animate(
                            from: color.start,
                            to: color.end,
                            updateBlock: { self.animatedBorderFilling = $0 }
                        )
                    )
                }

                if let thickness = value.thickness {
                    self.animatedBorderThickness = thickness.start

                    tokens.insert(
                        timeline.animate(
                            from: thickness.start,
                            to: thickness.end,
                            updateBlock: { self.animatedBorderThickness = $0 }
                        )
                    )
                }
            case let .innerShadow(timeline, value):
                guard #available(iOS 16.0, *) else { break }

                if let colorValue = value.color {
                    animatedInnerShadowFilling = colorValue.start
                }
                if let blurValue = value.blurRadius {
                    animatedInnerShadowBlurRadius = blurValue.start
                }
                if let offsetValue = value.offset {
                    animatedInnerShadowOffset = CGSize(
                        width: offsetValue.start.x.points(.horizontal, screenSize, safeArea),
                        height: offsetValue.start.y.points(.vertical, screenSize, safeArea)
                    )
                }

                tokens.insert(
                    timeline.animate(
                        from: (value.color?.start, value.blurRadius?.start, value.offset?.start),
                        to: (value.color?.end, value.blurRadius?.end, value.offset?.end),
                        updateBlock: { tuple in
                            if let colorValue = tuple.0 { animatedInnerShadowFilling = colorValue }
                            if let blurValue  = tuple.1 { animatedInnerShadowBlurRadius = blurValue }
                            if let offsetVal  = tuple.2 {
                                animatedInnerShadowOffset = CGSize(
                                    width:  offsetVal.x.points(.horizontal, screenSize, safeArea),
                                    height: offsetVal.y.points(.vertical,   screenSize, safeArea)
                                )
                            }
                        }
                    )
                )
            default:
                break
            }
        }

        self.animationTokens = tokens
    }
}

extension View {
    @ViewBuilder
    func animatableDecorator(
        _ decorator: VC.Decorator?,
        play: Binding<[VC.Animation]>,
        includeBackground: Bool
    ) -> some View {
        if let decorator {
            modifier(
                AdaptyUIAnimatableDecoratorModifier(
                    decorator: decorator,
                    play: play,
                    includeBackground: includeBackground
                )
            )
        } else {
            self
        }
    }
}

#endif
