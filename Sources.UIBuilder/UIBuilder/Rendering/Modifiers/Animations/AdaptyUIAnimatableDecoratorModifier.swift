//
//  AdaptyUIDecoratorModifier.swift
//
//
//  Created by Aleksey Goncharov on 24.05.2024.
//


import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension InsettableShape {
    @ViewBuilder
    func fill(
        _ filling: VC.Mode<VC.Filling>,
        colorScheme: ColorScheme,
        assetsResolver: AdaptyUIAssetsResolver
    ) -> some View {
        switch filling.resolve(with: assetsResolver, colorScheme: colorScheme) {
        case let .solidColor(color):
            self.fill(color)
        case let .colorGradient(gradient):
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
    }

    @ViewBuilder
    func stroke(
        filling: VC.Filling.Resolved?,
        lineWidth: CGFloat,
        assetsResolver: AdaptyUIAssetsResolver
    ) -> some View {
        if let filling {
            switch filling {
            case let .solidColor(color):
                self.strokeBorder(color, lineWidth: lineWidth)
            case let .colorGradient(.linear(gradient, startPoint, endPoint)):
                self.strokeBorder(LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint))
            case let .colorGradient(.angular(gradient, center, angle)):
                self.strokeBorder(AngularGradient(gradient: gradient, center: center, angle: angle))
            case let .colorGradient(.radial(gradient, center, startRadius, endRadius)):
                self.strokeBorder(RadialGradient(gradient: gradient, center: center, startRadius: startRadius, endRadius: endRadius))
            }
        } else {
            self
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func clipShape(_ shape: VC.ShapeType) -> some View {
        switch shape {
        case let .rectangle(radii):
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
                clipShape(UnevenRoundedRectangle(cornerRadii: radii.systemRadii))
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.ShapeType {
    @ViewBuilder
    func swiftUIShapeFill(
        _ filling: VC.Mode<VC.Filling>,
        colorScheme: ColorScheme,
        assetsResolver: AdaptyUIAssetsResolver
    ) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .fill(
                        filling,
                        colorScheme: colorScheme,
                        assetsResolver: assetsResolver
                    )
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .fill(
                        filling,
                        colorScheme: colorScheme,
                        assetsResolver: assetsResolver
                    )
            }
        case .circle:
            Circle()
                .fill(
                    filling,
                    colorScheme: colorScheme,
                    assetsResolver: assetsResolver
                )
        case .curveUp:
            CurveUpShape()
                .fill(
                    filling,
                    colorScheme: colorScheme,
                    assetsResolver: assetsResolver
                )
        case .curveDown:
            CurveDownShape()
                .fill(
                    filling,
                    colorScheme: colorScheme,
                    assetsResolver: assetsResolver
                )
        }
    }

    @ViewBuilder
    func swiftUIShapeStroke(
        _ filling: VC.Filling.Resolved?,
        lineWidth: CGFloat,
        assetsResolver: AdaptyUIAssetsResolver
    ) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .stroke(
                        filling: filling,
                        lineWidth: lineWidth,
                        assetsResolver: assetsResolver
                    )
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .stroke(
                        filling: filling,
                        lineWidth: lineWidth,
                        assetsResolver: assetsResolver
                    )
            }
        case .circle:
            Circle()
                .stroke(
                    filling: filling,
                    lineWidth: lineWidth,
                    assetsResolver: assetsResolver
                )
        case .curveUp:
            // Since there is no way to implement InsettableShape in a correct way, we make this hack with doubling the lineWidth
            CurveUpShape()
                .stroke(
                    filling: filling,
                    lineWidth: lineWidth * 2.0,
                    assetsResolver: assetsResolver
                )
        case .curveDown:
            CurveDownShape()
                .stroke(
                    filling: filling,
                    lineWidth: lineWidth * 2.0,
                    assetsResolver: assetsResolver
                )
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyUIAnimatableDecoratorModifier: ViewModifier {
    private let decorator: VC.Decorator
    private let includeBackground: Bool
    private let animations: [VC.Animation]?

    @State private var animatedBackgroundFilling: VC.Mode<VC.Filling>?

    private var initialBorderFilling: VC.Mode<VC.Filling>?
    private var initialBorderThickness: Double?

    @State private var animatedBorderFilling: VC.Mode<VC.Filling>?
    @State private var animatedBorderThickness: Double?

    @State private var animationTokens = Set<AdaptyUIAnimationToken>()

    private var resolvedBorderFilling: VC.Filling.Resolved? {
        (self.animatedBorderFilling ?? self.initialBorderFilling)?
            .resolve(
                with: self.assetsViewModel.assetsResolver,
                colorScheme: self.colorScheme
            )
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

    func body(content: Content) -> some View {
        self.bodyWithBackground(
            content: content
        )
        .overlay {
            if let borderFilling = resolvedBorderFilling, let borderThickness = resolvedBorderThickness {
                self.decorator.shapeType
                    .swiftUIShapeStroke(
                        borderFilling,
                        lineWidth: borderThickness,
                        assetsResolver: self.assetsViewModel.assetsResolver
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
                            animatedBackgroundFilling,
                            colorScheme: self.colorScheme,
                            assetsResolver: self.assetsViewModel.assetsResolver
                        )
                        .opacity(includeBackground ? 1.0 : 0.0)
                }
        } else if let background = self.decorator.background {
            switch background {
            case let .image(imageData):
                content
                    .background {
                        AdaptyUIImageView(
                            asset: imageData.usedColorScheme(self.colorScheme),
                            aspect: .fill,
                            tint: nil
                        )
                        .opacity(includeBackground ? 1.0 : 0.0)
                    }
            case let .filling(fillingValue):
                content
                    .background {
                        self.decorator.shapeType
                            .swiftUIShapeFill(
                                fillingValue,
                                colorScheme: self.colorScheme,
                                assetsResolver: self.assetsViewModel.assetsResolver
                            )
                            .opacity(includeBackground ? 1.0 : 0.0)
                    }
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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
