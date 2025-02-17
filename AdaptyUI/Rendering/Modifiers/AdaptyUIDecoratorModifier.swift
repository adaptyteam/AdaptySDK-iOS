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
extension InsettableShape {
    @ViewBuilder
    func fill(background: VC.Background?, colorScheme: ColorScheme) -> some View {
        if let background {
            switch background {
            case .image:
                self
            case let .filling(filling):
                switch filling.of(colorScheme) {
                case let .solidColor(color):
                    self.fill(color.swiftuiColor)
                case let .colorGradient(gradient):
                    switch gradient.kind {
                    case .linear:
                        self.fill(
                            LinearGradient(
                                stops: gradient.items
                                    .map { $0.gradientStop }
                                    .sorted(by: { $0.location > $1.location }),
                                startPoint: gradient.start.unitPoint,
                                endPoint: gradient.end.unitPoint
                            )
                        )
                    case .conic:
                        self.fill(
                            AngularGradient(
                                gradient: .init(
                                    stops: gradient.items
                                        .map { $0.gradientStop }
                                        .sorted(by: { $0.location > $1.location })
                                ),
                                center: .center,
                                angle: .degrees(360)
                            )
                        )
                    case .radial:
                        self.fill(
                            RadialGradient(
                                gradient: .init(
                                    stops: gradient.items
                                        .map { $0.gradientStop }
                                        .sorted(by: { $0.location > $1.location })
                                ),
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

    @ViewBuilder
    func stroke(filling: VC.Filling?, lineWidth: CGFloat) -> some View {
        if let filling {
            switch filling {
            case let .solidColor(color):
                self.strokeBorder(color.swiftuiColor, lineWidth: lineWidth)
            case let .colorGradient(gradient):
                switch gradient.kind {
                case .linear:
                    self.strokeBorder(
                        LinearGradient(
                            stops: gradient.items.map { $0.gradientStop },
                            startPoint: gradient.start.unitPoint,
                            endPoint: gradient.end.unitPoint
                        ),
                        lineWidth: lineWidth
                    )
                case .conic:
                    self.strokeBorder(
                        AngularGradient(
                            gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                            center: .center,
                            angle: .degrees(360)
                        ),
                        lineWidth: lineWidth
                    )
                case .radial:
                    self.strokeBorder(
                        RadialGradient(
                            gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                            center: .center,
                            startRadius: 0.0,
                            endRadius: 1.0
                        ),
                        lineWidth: lineWidth
                    )
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
extension VC.ShapeType {
    @ViewBuilder
    func swiftUIShapeFill(_ background: VC.Background?, colorScheme: ColorScheme) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .fill(background: background, colorScheme: colorScheme)
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .fill(background: background, colorScheme: colorScheme)
            }
        case .circle:
            Circle()
                .fill(background: background, colorScheme: colorScheme)
        case .curveUp:
            CurveUpShape()
                .fill(background: background, colorScheme: colorScheme)
        case .curveDown:
            CurveDownShape()
                .fill(background: background, colorScheme: colorScheme)
        }
    }

    @ViewBuilder
    func swiftUIShapeStroke(_ filling: VC.Filling?, lineWidth: CGFloat) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .stroke(filling: filling, lineWidth: lineWidth)
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .stroke(filling: filling, lineWidth: lineWidth)
            }
        case .circle:
            Circle()
                .stroke(filling: filling, lineWidth: lineWidth)
        case .curveUp:
            // Since there is no way to implement InsettableShape in a correct way, we make this hack with doubling the lineWidth
            CurveUpShape()
                .stroke(filling: filling, lineWidth: lineWidth * 2.0)
        case .curveDown:
            CurveDownShape()
                .stroke(filling: filling, lineWidth: lineWidth * 2.0)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyUIDecoratorModifier: ViewModifier {
    var decorator: VC.Decorator
    var includeBackground: Bool

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
                                asset: imageData.of(self.colorScheme),
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
                                .swiftUIShapeFill(self.decorator.background, colorScheme: self.colorScheme)
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
                        border.filling.of(self.colorScheme),
                        lineWidth: border.thickness
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
