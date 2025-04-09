//
//  AdaptyUIDecoratorModifier.swift
//
//
//  Created by Aleksey Goncharov on 24.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Mode {
    func of(_ colorScheme: ColorScheme) -> T {
        switch colorScheme {
        case .light: mode(.light)
        case .dark: mode(.dark)
        @unknown default: mode(.light)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension AdaptyViewConfiguration.ColorGradient {
    func stops(_ assetsResolver: AdaptyAssetsResolver) -> [Gradient.Stop] {
        let result = items
            .map { $0.gradientStop(assetsResolver) }
            .sorted(by: { $0.location < $1.location })

        return result
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension InsettableShape {
    @ViewBuilder
    func fill(
        _ filling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>,
        colorScheme: ColorScheme,
        assetsResolver: AdaptyAssetsResolver
    ) -> some View {
        switch filling.of(colorScheme) {
        case let .solidColor(color):
            self.fill(color.swiftuiColor(assetsResolver))
        case let .colorGradient(gradient):
            if let customId = gradient.customId,
               case let .gradient(customGradient) = assetsResolver.asset(for: customId)
            {
                switch customGradient {
                case let .linear(gradient, startPoint, endPoint):
                    self.fill(
                        LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
                    )
                case let .angular(gradient, center, angle):
                    self.fill(
                        AngularGradient(gradient: gradient, center: center, angle: angle)
                    )
                case let .radial(gradient, center, startRadius, endRadius):
                    self.fill(
                        RadialGradient(gradient: gradient, center: center, startRadius: startRadius, endRadius: endRadius)
                    )
                }
            } else {
                switch gradient.kind {
                case .linear:
                    self.fill(
                        LinearGradient(
                            gradient: .init(stops: gradient.stops(assetsResolver)),
                            startPoint: gradient.start.unitPoint,
                            endPoint: gradient.end.unitPoint
                        )
                    )
                case .conic:
                    self.fill(
                        AngularGradient(
                            gradient: .init(stops: gradient.stops(assetsResolver)),
                            center: .center,
                            angle: .degrees(360)
                        )
                    )
                case .radial:
                    self.fill(
                        RadialGradient(
                            gradient: .init(stops: gradient.stops(assetsResolver)),
                            center: .center,
                            startRadius: 0.0,
                            endRadius: 1.0
                        )
                    )
                }
            }
        }
    }

    @ViewBuilder
    func stroke(
        filling: VC.Filling?,
        lineWidth: CGFloat,
        assetsResolver: AdaptyAssetsResolver
    ) -> some View {
        if let filling {
            switch filling {
            case let .solidColor(color):
                self.strokeBorder(
                    color.swiftuiColor(assetsResolver),
                    lineWidth: lineWidth
                )
            case let .colorGradient(gradient):
                if let customId = gradient.customId,
                   case let .gradient(customGradient) = assetsResolver.asset(for: customId)
                {
                    switch customGradient {
                    case let .linear(gradient, startPoint, endPoint):
                        self.strokeBorder(
                            LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
                        )
                    case let .angular(gradient, center, angle):
                        self.strokeBorder(
                            AngularGradient(gradient: gradient, center: center, angle: angle)
                        )
                    case let .radial(gradient, center, startRadius, endRadius):
                        self.strokeBorder(
                            RadialGradient(gradient: gradient, center: center, startRadius: startRadius, endRadius: endRadius)
                        )
                    }
                } else {
                    switch gradient.kind {
                    case .linear:
                        self.strokeBorder(
                            LinearGradient(
                                gradient: .init(stops: gradient.stops(assetsResolver)),
                                startPoint: gradient.start.unitPoint,
                                endPoint: gradient.end.unitPoint
                            )
                        )
                    case .conic:
                        self.strokeBorder(
                            AngularGradient(
                                gradient: .init(stops: gradient.stops(assetsResolver)),
                                center: .center,
                                angle: .degrees(360)
                            )
                        )
                    case .radial:
                        self.strokeBorder(
                            RadialGradient(
                                gradient: .init(stops: gradient.stops(assetsResolver)),
                                center: .center,
                                startRadius: 0.0,
                                endRadius: 1.0
                            )
                        )
                    }
                }
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
            if #available(iOS 16.0, *) {
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
        _ filling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>,
        colorScheme: ColorScheme,
        assetsResolver: AdaptyAssetsResolver
    ) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
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
        _ filling: VC.Filling?,
        lineWidth: CGFloat,
        assetsResolver: AdaptyAssetsResolver
    ) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
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
    private let animations: [AdaptyViewConfiguration.Animation]?

    @State private var animatedBackgroundFilling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>?

    private var initialBorderFilling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>?
    private var initialBorderThickness: Double?

    @State private var animatedBorderFilling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>?
    @State private var animatedBorderThickness: Double?

    private var resolvedBorderFilling: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>? {
        self.animatedBorderFilling ?? self.initialBorderFilling
    }

    private var resolvedBorderThickness: Double? {
        self.animatedBorderThickness ?? self.initialBorderThickness
    }

    init(
        decorator: VC.Decorator,
        animations: [AdaptyViewConfiguration.Animation]?,
        includeBackground: Bool
    ) {
        self.decorator = decorator
        self.animations = animations
        self.includeBackground = includeBackground

        self.initialBorderFilling = decorator.border?.filling
        self.initialBorderThickness = decorator.border?.thickness
    }

    @EnvironmentObject
    private var assetsViewModel: AdaptyAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    func body(content: Content) -> some View {
        self.bodyWithBackground(
            content: content
        )
        .overlay {
            if let border = decorator.border {
                self.decorator.shapeType
                    .swiftUIShapeStroke(
                        self.resolvedBorderFilling?.of(self.colorScheme),
                        lineWidth: self.resolvedBorderThickness ?? 0.0,
                        assetsResolver: self.assetsViewModel.assetsResolver
                    )
            }
        }
        .clipShape(self.decorator.shapeType)
        .onAppear {
            self.startAnimations()
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
                            animatedBackgroundFilling,
                            colorScheme: self.colorScheme,
                            assetsResolver: self.assetsViewModel.assetsResolver
                        )
                }
        } else if let background = self.decorator.background {
            switch background {
            case let .image(imageData):
                content
                    .background {
                        AdaptyUIImageView(
                            asset: imageData.of(self.colorScheme),
                            aspect: .fill,
                            tint: nil
                        )
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
                    }
            }
        } else {
            content
        }
    }

    private func startAnimations() {
        guard let animations, !animations.isEmpty else { return }

        for animation in animations {
            switch animation {
            case let .background(timeline, value):
                self.animatedBackgroundFilling = value.start
                self.startValueAnimation(
                    animation,
                    from: value.start,
                    to: value.end
                ) { self.animatedBackgroundFilling = $0 }
            case let .border(timeline, value):
                self.animatedBorderThickness = value.thickness?.start

                if let color = value.color {
                    self.animatedBorderFilling = value.color?.start

                    self.startValueAnimation(
                        animation,
                        from: color.start,
                        to: color.end
                    ) { self.animatedBorderFilling = $0 }
                }

                if let thickness = value.thickness {
                    self.animatedBorderThickness = thickness.start ?? 0.0

                    self.startValueAnimation(
                        animation,
                        from: thickness.start,
                        to: thickness.end
                    ) { self.animatedBorderThickness = $0 }
                }
            default:
                break
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func animatableDecorator(
        _ decorator: VC.Decorator?,
        animations: [AdaptyViewConfiguration.Animation]?,
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
