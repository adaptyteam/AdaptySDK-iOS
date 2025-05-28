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
@MainActor
extension InsettableShape {
    @ViewBuilder
    func fill(
        background: VC.Background?,
        colorScheme: ColorScheme,
        assetsResolver: AdaptyAssetsResolver
    ) -> some View {
        if let background {
            switch background {
            case .image:
                self
            case let .filling(filling):
                switch filling.resolve(with: assetsResolver, colorScheme: colorScheme) {
                case let .solidColor(color):
                    self.fill(color)
                case let .colorGradient(.linear(gradient, startPoint, endPoint)):
                    self.fill(LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint))
                case let .colorGradient(.angular(gradient, center, angle)):
                    self.fill(AngularGradient(gradient: gradient, center: center, angle: angle))
                case let .colorGradient(.radial(gradient, center, startRadius, endRadius)):
                    self.fill(RadialGradient(gradient: gradient, center: center, startRadius: startRadius, endRadius: endRadius))
                }
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func stroke(
        filling: VC.Filling?,
        lineWidth: CGFloat,
        assetsResolver: AdaptyAssetsResolver
    ) -> some View {
        if let filling {
            switch filling.resolve(with: assetsResolver) {
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
        _ background: VC.Background?,
        colorScheme: ColorScheme,
        assetsResolver: AdaptyAssetsResolver
    ) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .fill(
                        background: background,
                        colorScheme: colorScheme,
                        assetsResolver: assetsResolver
                    )
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .fill(
                        background: background,
                        colorScheme: colorScheme,
                        assetsResolver: assetsResolver
                    )
            }
        case .circle:
            Circle()
                .fill(
                    background: background,
                    colorScheme: colorScheme,
                    assetsResolver: assetsResolver
                )
        case .curveUp:
            CurveUpShape()
                .fill(
                    background: background,
                    colorScheme: colorScheme,
                    assetsResolver: assetsResolver
                )
        case .curveDown:
            CurveDownShape()
                .fill(
                    background: background,
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
struct AdaptyUIDecoratorModifier: ViewModifier {
    var decorator: VC.Decorator
    var includeBackground: Bool

    @EnvironmentObject
    private var assetsViewModel: AdaptyAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @ViewBuilder
    private func bodyWithBackground(content: Content, background: VC.Background?) -> some View {
        if let background {
            switch background {
            case let .image(imageData):
                content
                    .background {
                        if self.includeBackground {
                            AdaptyUIImageView(
                                asset: imageData.usedColorScheme(self.colorScheme),
                                aspect: .fill,
                                tint: nil
                            )
                        }
                    }
            default:
                content
                    .background {
                        if self.includeBackground {
                            self.decorator.shapeType
                                .swiftUIShapeFill(
                                    self.decorator.background,
                                    colorScheme: self.colorScheme,
                                    assetsResolver: self.assetsViewModel.assetsResolver
                                )
                        }
                    }
            }
        } else {
            content
        }
    }

    func body(content: Content) -> some View {
        self.bodyWithBackground(
            content: content,
            background: self.decorator.background
        )
        .overlay {
            if let border = decorator.border {
                self.decorator.shapeType
                    .swiftUIShapeStroke(
                        border.filling.usedColorScheme(self.colorScheme),
                        lineWidth: border.thickness,
                        assetsResolver: self.assetsViewModel.assetsResolver
                    )
            }
        }
        .clipShape(self.decorator.shapeType)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func decorate(
        with decorator: VC.Decorator?,
        includeBackground: Bool
    ) -> some View {
        if let decorator {
            modifier(
                AdaptyUIDecoratorModifier(
                    decorator: decorator,
                    includeBackground: includeBackground
                )
            )
        } else {
            self
        }
    }
}

#endif
