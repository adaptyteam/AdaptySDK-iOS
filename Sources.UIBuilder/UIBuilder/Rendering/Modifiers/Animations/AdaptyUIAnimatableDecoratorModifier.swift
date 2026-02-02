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
            self
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
                .stroke(asset: asset, lineWidth: lineWidth)
        case .curveDown:
            CurveDownShape()
                .stroke(asset: asset, lineWidth: lineWidth)
        }
    }
}

@MainActor
struct AdaptyUIAnimatableDecoratorModifier: ViewModifier {
    private let decorator: VC.Decorator
    private let includeBackground: Bool
    private let animations: [VC.Animation]?

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

    init(
        decorator: VC.Decorator,
        animations: [VC.Animation]?,
        includeBackground: Bool
    ) {
        self.decorator = decorator
        self.animations = animations
        self.includeBackground = includeBackground

        self.initialBorderFilling = decorator.border?.filling
        self.initialBorderThickness = decorator.border?.thickness
    }

    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

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
        .onAppear {
            self.startAnimations()
        }
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
                    self.decorator.shapeType
                        .swiftUIShapeFill(
                            asset: self.assetsViewModel.resolvedAsset(
                                animatedBackgroundFilling,
                                mode: self.colorScheme.toVCMode,
                                screen: screen
                            ).asColorOrGradientOrImageAsset
                        )
                        .opacity(includeBackground ? 1.0 : 0.0)
                }
        } else if let background = self.decorator.background {
            content
                .background {
                    self.decorator.shapeType
                        .swiftUIShapeFill(
                            asset: self.assetsViewModel.resolvedAsset(
                                background,
                                mode: self.colorScheme.toVCMode,
                                screen: screen
                            ).asColorOrGradientOrImageAsset
                        )
                }
        } else {
            content
        }
    }

    private func startAnimations() {
        guard let animations, !animations.isEmpty else { return }

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
        animations: [VC.Animation]?,
        includeBackground: Bool
    ) -> some View {
        if let decorator {
            modifier(
                AdaptyUIAnimatableDecoratorModifier(
                    decorator: decorator,
                    animations: animations,
                    includeBackground: includeBackground
                )
            )
        } else {
            self
        }
    }
}

#endif
