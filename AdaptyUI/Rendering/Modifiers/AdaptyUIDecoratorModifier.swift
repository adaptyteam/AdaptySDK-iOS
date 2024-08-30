//
//  AdaptyUIDecoratorModifier.swift
//
//
//  Created by Aleksey Goncharov on 24.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

extension AdaptyUI.Mode {
    var NEED_TO_CHOOSE_MODE: T { mode(.light) }
}

@available(iOS 15.0, *)
extension InsettableShape {
    @ViewBuilder
    func fill(background: AdaptyUI.Background?) -> some View {
        if let background {
            switch background {
            case .image:
                self
            case let .filling(filling):

                switch filling.NEED_TO_CHOOSE_MODE {
                case let .color(color):
                    self.fill(color.swiftuiColor)
                case let .colorGradient(gradient):
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
                }
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func stroke(filling: AdaptyUI.Filling?, lineWidth: CGFloat) -> some View {
        if let filling {
            switch filling {
            case let .color(color):
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

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func clipShape(_ shape: AdaptyUI.ShapeType) -> some View {
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

@available(iOS 15.0, *)
extension AdaptyUI.ShapeType {
    @ViewBuilder
    func swiftUIShapeFill(_ background: AdaptyUI.Background?) -> some View {
        switch self {
        case let .rectangle(radii):
            if #available(iOS 16.0, *) {
                UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                    .fill(background: background)
            } else {
                UnevenRoundedRectangleFallback(cornerRadii: radii)
                    .fill(background: background)
            }
        case .circle:
            Circle()
                .fill(background: background)
        case .curveUp:
            CurveUpShape()
                .fill(background: background)
        case .curveDown:
            CurveDownShape()
                .fill(background: background)
        }
    }

    @ViewBuilder
    func swiftUIShapeStroke(_ filling: AdaptyUI.Filling?, lineWidth: CGFloat) -> some View {
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
    private func bodyWithBackground(content: Content, background: AdaptyUI.Background?) -> some View {
        if let background {
            switch background {
            case let .image(imageData):
                content
                    .background {
                        if includeBackground {
                            AdaptyUIImageView(
                                asset: imageData.NEED_TO_CHOOSE_MODE,
                                aspect: .fill,
                                tint: nil
                            )
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
                        border.filling.NEED_TO_CHOOSE_MODE,
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
    func decorate(
        with decorator: AdaptyUI.Decorator?,
        includeBackground: Bool
    ) -> some View {
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
