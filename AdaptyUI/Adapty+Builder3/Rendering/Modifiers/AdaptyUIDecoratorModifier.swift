//
//  AdaptyUIDecoratorModifier.swift
//
//
//  Created by Aleksey Goncharov on 24.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 13.0, *)
extension Shape {
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
                    // TODO: check implementation
                    self.fill(
                        AngularGradient(
                            gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                            center: .center,
                            angle: .degrees(360)
                        )
                    )
                case .radial:
                    // TODO: check implementation
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
    func stroke(filling: AdaptyUI.Filling?, lineWidth: CGFloat) -> some View {
        if let filling {
            switch filling {
            case .color(let color):
                self.stroke(color.swiftuiColor, lineWidth: lineWidth)
            case .colorGradient(let gradient):
                switch gradient.kind {
                case .linear:
                    self.stroke(
                        LinearGradient(
                            stops: gradient.items.map { $0.gradientStop },
                            startPoint: gradient.start.unitPoint,
                            endPoint: gradient.end.unitPoint
                        ),
                        lineWidth: lineWidth
                    )
                case .conic:
                    // TODO: check implementation
                    self.stroke(
                        AngularGradient(
                            gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                            center: .center,
                            angle: .degrees(360)
                        ),
                        lineWidth: lineWidth
                    )
                case .radial:
                    // TODO: check implementation
                    self.stroke(
                        RadialGradient(
                            gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                            center: .center,
                            startRadius: 0.0,
                            endRadius: 1.0
                        ),
                        lineWidth: lineWidth
                    )
                }
            case .image(let imageData):
                self
            }
        } else {
            self
        }
    }
}

@available(iOS 13.0, *)
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
            self
        case .curveDown:
            self
        }
    }
}

@available(iOS 13.0, *)
extension AdaptyUI.ShapeType {
    @ViewBuilder
    func swiftUIShapeFill(_ filling: AdaptyUI.Filling?) -> some View {
        switch self {
        case .rectangle(let cornerRadii):
            UnevenRoundedRectangleFallback(cornerRadii: cornerRadii)
                .fill(filling: filling)
        case .circle:
            Circle()
                .fill(filling: filling)
        case .curveUp: // TODO: implement shape
            Rectangle()
                .fill(filling: filling)
        case .curveDown: // TODO: implement shape
            Rectangle()
                .fill(filling: filling)
        }
    }

    @ViewBuilder
    func swiftUIShapeStroke(_ filling: AdaptyUI.Filling?, lineWidth: CGFloat) -> some View {
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
        case .curveUp: // TODO: implement shape
            Rectangle()
                .stroke(filling: filling, lineWidth: lineWidth)
        case .curveDown: // TODO: implement shape
            Rectangle()
                .stroke(filling: filling, lineWidth: lineWidth)
        }
    }
}

@available(iOS 15.0, *)
struct AdaptyUIDecoratorModifier: ViewModifier {
    var decorator: AdaptyUI.Decorator

    func body(content: Content) -> some View {
        content
            .background {
                if let background = decorator.background {
                    self.decorator.shapeType
                        .swiftUIShapeFill(self.decorator.background)
                        .overlay {
                            if let border = decorator.border {
                                self.decorator.shapeType
                                    .swiftUIShapeStroke(
                                        border.filling,
                                        lineWidth: border.thickness
                                    )
                            }
                        }
                } else if let border = decorator.border {
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

@available(iOS 13.0, *)
extension View {
    @ViewBuilder
    func decorate(with decorator: AdaptyUI.Decorator?) -> some View {
        if #available(iOS 15.0, *), let decorator {
            modifier(AdaptyUIDecoratorModifier(decorator: decorator))
        } else {
            self
        }
    }
}

#if DEBUG

@available(iOS 13.0, *)
#Preview {
    Text("Hello world!")
        .foregroundColor(.white)
        .bold()
        .padding()
        .decorate(with:
            .create(
                //                shapeType: .circle,
                shapeType: .rectangle(cornerRadius: .create(topLeading: 24,
                                                            bottomTrailing: 24)),
//                background: .color(.testGreen),
                background: .colorGradient(.create(
                    kind: .conic,
                    start: .create(x: 0.0, y: 0.0),
                    end: .create(x: 1.0, y: 1.0),
                    items: [
                        .create(color: .testBlue, p: 0.0),
                        .create(color: .testRed, p: 1.0),
                    ]
                )),
                border: .createColor(filling: .colorGradient(.create(
                    kind: .linear,
                    start: .create(x: 0.0, y: 1.0),
                    end: .create(x: 1.0, y: 0.0),
                    items: [
                        .create(color: .testGreen, p: 0.0),
                        .create(color: .testBlack, p: 1.0),
                    ]
                )), thickness: 4.0)
//                border: .createColor(filling: .color(.testBlack), thickness: 5.0)
            )
        )
}

#endif

#endif
