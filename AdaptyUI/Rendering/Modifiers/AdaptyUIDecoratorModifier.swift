//
//  AdaptyUIDecoratorModifier.swift
//
//
//  Created by Aleksey Goncharov on 24.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
extension InsettableShape {
    @ViewBuilder
    func fill(filling: AdaptyUI.Filling?) -> some View {
        if let filling {
            switch filling {
            case .color(let color):
                self.fill(color.swiftuiColor)
            case .colorGradient(let gradient):
                self.fill(
                    LinearGradient(
                        stops: gradient.items.map { $0.gradientStop },
                        startPoint: gradient.start.unitPoint,
                        endPoint: gradient.end.unitPoint
                    )
                )
                switch gradient.kind {
                case .linear:
                    self.fill(
                        LinearGradient(
                            stops: gradient.items.map { $0.gradientStop },
                            startPoint: gradient.start.unitPoint,
                            endPoint: gradient.end.unitPoint
                        )
                    )
                case .conic:
                    self.fill(
                        AngularGradient(
                            gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                            center: .center,
                            angle: .degrees(360)
                        )
                    )
                case .radial:
                    self.fill(
                        RadialGradient(
                            gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                            center: .center,
                            startRadius: 0.0,
                            endRadius: 1.0
                        )
                    )
                }
            case .image(let imageData):
                self
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func stroke(filling: AdaptyUI.ColorFilling?, lineWidth: CGFloat) -> some View {
        if let filling {
            switch filling {
            case .color(let color):
                self.strokeBorder(color.swiftuiColor, lineWidth: lineWidth)
            case .colorGradient(let gradient):
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

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func clipShape(_ shape: AdaptyUI.ShapeType) -> some View {
        switch shape {
        case .rectangle(let radii):
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

@available(iOS 15.0, *)
extension AdaptyUI.ShapeType {
    @ViewBuilder
    func swiftUIShapeFill(_ filling: AdaptyUI.Filling?) -> some View {
        switch self {
        case .rectangle(let radii):
            if #available(iOS 16.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .fill(filling: filling)
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .fill(filling: filling)
            }
        case .circle:
            Circle()
                .fill(filling: filling)
        case .curveUp:
            CurveUpShape()
                .fill(filling: filling)
        case .curveDown:
            CurveDownShape()
                .fill(filling: filling)
        }
    }

    @ViewBuilder
    func swiftUIShapeStroke(_ filling: AdaptyUI.ColorFilling?, lineWidth: CGFloat) -> some View {
        switch self {
        case .rectangle(let radii):
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
            CurveUpShape()
                .stroke(filling: filling, lineWidth: lineWidth)
        case .curveDown:
            CurveDownShape()
                .stroke(filling: filling, lineWidth: lineWidth)
        }
    }
}

@available(iOS 15.0, *)
struct AdaptyUIDecoratorModifier: ViewModifier {
    var decorator: AdaptyUI.Decorator
    var includeBackground: Bool

    @ViewBuilder
    private func bodyWithBackground(content: Content, background: AdaptyUI.Filling?) -> some View {
        if let background {
            switch background {
            case .image(let imageData):
                content
                    .background {
                        if includeBackground {
                            AdaptyUIImageView(asset: imageData,
                                              aspect: .fill,
                                              tint: nil)
                        }
                    }
            default:
                content
                    .background {
                        if includeBackground {
                            self.decorator.shapeType
                                .swiftUIShapeFill(self.decorator.background)
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
                        border.filling,
                        lineWidth: border.thickness
                    )
            }
        }
        .clipShape(self.decorator.shapeType)
    }
}

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func decorate(with decorator: AdaptyUI.Decorator?,
                  includeBackground: Bool) -> some View
    {
        if let decorator {
            modifier(AdaptyUIDecoratorModifier(
                decorator: decorator,
                includeBackground: includeBackground
            ))
        } else {
            self
        }
    }
}

#endif
