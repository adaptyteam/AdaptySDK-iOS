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
        _ image: VC.ImageData.Resolved
    ) -> some View {
        self.background {
            AdaptyUIImageView(
                asset: image,
                aspect: .fill
            )
        }
    }

    @ViewBuilder
    func fillSolidColor(
        _ color: VC.Color.Resolved
    ) -> some View {
        self.fill(color)
    }

    @ViewBuilder
    func fillColorGradient(
        _ gradient: VC.ColorGradient.Resolved
    ) -> some View {
        switch gradient {
        case let .linear(gradient, start, stop):
            self.fill(
                LinearGradient(
                    gradient: gradient,
                    startPoint: start,
                    endPoint: stop
                )
            )
        case let .angular(gradient, center, angle):
            self.fill(
                AngularGradient(
                    gradient: gradient,
                    center: center,
                    angle: angle
                )
            )
        case let .radial(gradient, center, startRadius, endRadius):
            self.fill(
                RadialGradient(
                    gradient: gradient,
                    center: center,
                    startRadius: startRadius,
                    endRadius: endRadius
                )
            )
        }
    }

    @ViewBuilder
    private func fill(
        asset: VC.Asset,
        mode: VC.Mode
    ) -> some View {
        background {
            switch asset {
            case let .solidColor(color):
                self.fillSolidColor(color.resolved)
            case let .colorGradient(colorGradient):
                self.fillColorGradient(colorGradient.resolved)
            case let .image(imageData):
                self.fillImage(imageData.resolved)
            case .video, .font, .unknown:
                self
            }
        }
    }

    @ViewBuilder
    func fill(
        assetReference: VC.AssetReference?,
        mode: VC.Mode,
        assetsResolver: AdaptyUIAssetsResolver,
        stateViewModel: AdaptyUIStateViewModel
    ) -> some View {
        if let asset = stateViewModel.asset(assetReference, mode: mode, defaultValue: nil) {
            if let customId = asset.customId,
               let customAsset = assetsResolver.asset(for: customId)
            {
                switch customAsset {
                case let .color(customColorAsset):
                    self.fillSolidColor(customColorAsset.resolved)
                case let .gradient(customGradientAsset):
                    self.fillColorGradient(customGradientAsset)
                case let .image(customImageAsset):
                    if let resolvedCustomAsset = customImageAsset.resolved {
                        self.fillImage(resolvedCustomAsset)
                    } else {
                        self.fill(
                            asset: asset,
                            mode: mode
                        )
                    }
                default:
                    self.fill(
                        asset: asset,
                        mode: mode
                    )
                }
            } else {
                self.fill(
                    asset: asset,
                    mode: mode
                )
            }
        } else {
            self
        }
    }
}

@MainActor
extension InsettableShape {
    @ViewBuilder
    func strokeSolidColor(
        _ color: VC.Color.Resolved,
        lineWidth: CGFloat
    ) -> some View {
        self.strokeBorder(color, lineWidth: lineWidth)
    }

    @ViewBuilder
    func strokeColorGradient(
        _ gradient: VC.ColorGradient.Resolved,
        lineWidth: CGFloat
    ) -> some View {
        switch gradient {
        case let .linear(gradient, startPoint, endPoint):
            self.strokeBorder(
                LinearGradient(
                    gradient: gradient,
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
        case let .angular(gradient, center, angle):
            self.strokeBorder(
                AngularGradient(
                    gradient: gradient,
                    center: center,
                    angle: angle
                )
            )
        case let .radial(gradient, center, startRadius, endRadius):
            self.strokeBorder(
                RadialGradient(
                    gradient: gradient,
                    center: center,
                    startRadius: startRadius,
                    endRadius: endRadius
                )
            )
        }
    }

    @ViewBuilder
    private func stroke(
        asset: VC.Asset,
        mode: VC.Mode,
        lineWidth: CGFloat
    ) -> some View {
        switch asset {
        case let .solidColor(color):
            self.strokeSolidColor(color.resolved, lineWidth: lineWidth)
        case let .colorGradient(colorGradient):
            self.strokeColorGradient(colorGradient.resolved, lineWidth: lineWidth)
        case .image, .video, .font, .unknown:
            self
        }
    }

    @ViewBuilder
    func stroke(
        assetReference: VC.AssetReference?,
        mode: VC.Mode,
        lineWidth: CGFloat,
        assetsResolver: AdaptyUIAssetsResolver,
        stateViewModel: AdaptyUIStateViewModel
    ) -> some View {
        if let asset = stateViewModel.asset(assetReference, mode: mode, defaultValue: nil) {
            if let customId = asset.customId,
               let customAsset = assetsResolver.asset(for: customId)
            {
                switch customAsset {
                case let .color(customColorAsset):
                    self.strokeSolidColor(
                        customColorAsset.resolved,
                        lineWidth: lineWidth
                    )
                case let .gradient(customGradientAsset):
                    self.strokeColorGradient(
                        customGradientAsset,
                        lineWidth: lineWidth
                    )
                default:
                    self.stroke(asset: asset, mode: mode, lineWidth: lineWidth)
                }
            } else {
                self.stroke(asset: asset, mode: mode, lineWidth: lineWidth)
            }
        } else {
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
        assetReference: VC.AssetReference?,
        mode: VC.Mode,
        assetsResolver: AdaptyUIAssetsResolver,
        stateViewModel: AdaptyUIStateViewModel
    ) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .fill(
                        assetReference: assetReference,
                        mode: mode,
                        assetsResolver: assetsResolver,
                        stateViewModel: stateViewModel
                    )
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .fill(
                        assetReference: assetReference,
                        mode: mode,
                        assetsResolver: assetsResolver,
                        stateViewModel: stateViewModel
                    )
            }
        case .circle:
            Circle()
                .fill(
                    assetReference: assetReference,
                    mode: mode,
                    assetsResolver: assetsResolver,
                    stateViewModel: stateViewModel
                )
        case .curveUp:
            CurveUpShape()
                .fill(
                    assetReference: assetReference,
                    mode: mode,
                    assetsResolver: assetsResolver,
                    stateViewModel: stateViewModel
                )
        case .curveDown:
            CurveDownShape()
                .fill(
                    assetReference: assetReference,
                    mode: mode,
                    assetsResolver: assetsResolver,
                    stateViewModel: stateViewModel
                )
        }
    }

    @ViewBuilder
    func swiftUIShapeStroke(
        _ assetReference: VC.AssetReference?,
        mode: VC.Mode,
        lineWidth: CGFloat,
        assetsResolver: AdaptyUIAssetsResolver,
        stateViewModel: AdaptyUIStateViewModel
    ) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .stroke(
                        assetReference: assetReference,
                        mode: mode,
                        lineWidth: lineWidth,
                        assetsResolver: assetsResolver,
                        stateViewModel: stateViewModel
                    )
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .stroke(
                        assetReference: assetReference,
                        mode: mode,
                        lineWidth: lineWidth,
                        assetsResolver: assetsResolver,
                        stateViewModel: stateViewModel
                    )
            }
        case .circle:
            Circle()
                .stroke(
                    assetReference: assetReference,
                    mode: mode,
                    lineWidth: lineWidth,
                    assetsResolver: assetsResolver,
                    stateViewModel: stateViewModel
                )
        case .curveUp:
            // Since there is no way to implement InsettableShape in a correct way, we make this hack with doubling the lineWidth
            CurveUpShape()
                .stroke(
                    assetReference: assetReference,
                    mode: mode,
                    lineWidth: lineWidth,
                    assetsResolver: assetsResolver,
                    stateViewModel: stateViewModel
                )
        case .curveDown:
            CurveDownShape()
                .stroke(
                    assetReference: assetReference,
                    mode: mode,
                    lineWidth: lineWidth,
                    assetsResolver: assetsResolver,
                    stateViewModel: stateViewModel
                )
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
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    func body(content: Content) -> some View {
        self.bodyWithBackground(
            content: content
        )
        .overlay {
            if let borderFilling = resolvedBorderFilling, let borderThickness = resolvedBorderThickness {
                self.decorator.shapeType
                    .swiftUIShapeStroke(
                        borderFilling,
                        mode: self.colorScheme.toVCMode,
                        lineWidth: borderThickness,
                        assetsResolver: self.assetsViewModel.assetsResolver,
                        stateViewModel: self.stateViewModel
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
        if !self.includeBackground {
            content
        } else if let animatedBackgroundFilling {
            content
                .background {
                    self.decorator.shapeType
                        .swiftUIShapeFill(
                            assetReference: animatedBackgroundFilling,
                            mode: self.colorScheme.toVCMode,
                            assetsResolver: self.assetsViewModel.assetsResolver,
                            stateViewModel: self.stateViewModel
                        )
                }
        } else if let background = self.decorator.background {
            content
                .background {
                    self.decorator.shapeType
                        .swiftUIShapeFill(
                            assetReference: background,
                            mode: self.colorScheme.toVCMode,
                            assetsResolver: self.assetsViewModel.assetsResolver,
                            stateViewModel: self.stateViewModel
                        )
                }
//
//            switch background {
//            case let .image(imageData):
//                content
//                    .background {
//                        AdaptyUIImageView(
//                            asset: imageData.usedColorScheme(self.colorScheme),
//                            aspect: .fill
//                        )
//                    }
//            case let .filling(fillingValue):
//                content
//                    .background {
//                        self.decorator.shapeType
//                            .swiftUIShapeFill(
//                                animatedBackgroundFilling,
//                                mode: self.colorScheme.toVCMode,
//                                assetsResolver: self.assetsViewModel.assetsResolver,
//                                stateViewModel: self.stateViewModel
//                            )
//                    }
//            }
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
