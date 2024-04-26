//
//  AdaptyUI+ElementProperties.swift
//
//
//  Created by Aleksey Goncharov on 3.4.24..
//

import Adapty
import SwiftUI

extension AdaptyUI.Point {
    var unitPoint: UnitPoint { UnitPoint(x: x, y: y) }
}

extension AdaptyUI.ColorGradient.Item {
    var gradientStop: Gradient.Stop { Gradient.Stop(color: color.swiftuiColor, location: p) }
}

struct AdaptyUIGradient: View {
    var gradient: AdaptyUI.ColorGradient

    init(_ gradient: AdaptyUI.ColorGradient) {
        self.gradient = gradient
    }

    var body: some View {
        switch gradient.kind {
        case .linear:
            LinearGradient(
                stops: gradient.items.map { $0.gradientStop },
                startPoint: gradient.start.unitPoint,
                endPoint: gradient.end.unitPoint
            )
        case .conic:
            // TODO: check implementation
            AngularGradient(
                gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                center: .center,
                angle: .degrees(360)
            )
        case .radial:
            // TODO: check implementation
            RadialGradient(
                gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                center: .center,
                startRadius: 0.0,
                endRadius: 1.0
            )
        }
    }
}

struct AdaptyUIDecoratorView: View {
    var decorator: AdaptyUI.Decorator

    init(_ decorator: AdaptyUI.Decorator) {
        self.decorator = decorator
    }

    private func roundedRectangle(radius: AdaptyUI.CornerRadius) -> RoundedRectangle {
        if radius.isSameRadius {
            return RoundedRectangle(cornerRadius: radius.topLeft)
        } else {
            return RoundedRectangle(cornerRadius: 0.0)
        }
    }

    var body: some View {
        switch decorator.shapeType {
        case let .rectangle(cornerRadius):
            roundedRectangle(radius: cornerRadius)
                .fillBackground(decorator.background)
                .overlayBorder(decorator.border, shape: decorator.shapeType)
        case .circle:
            Circle()
                .fillBackground(decorator.background)
                .overlayBorder(decorator.border, shape: decorator.shapeType)
        case .curveUp:
            // TODO: implement
            Rectangle()
                .fillBackground(decorator.background)
                .overlayBorder(decorator.border, shape: decorator.shapeType)
        case .curveDown:
            // TODO: implement
            Rectangle()
                .fillBackground(decorator.background)
                .overlayBorder(decorator.border, shape: decorator.shapeType)
        }
    }
}

struct AdaptyUIOverlayBorderView: View {
    var border: AdaptyUI.Border
    var shape: AdaptyUI.ShapeType

    init(_ border: AdaptyUI.Border, shape: AdaptyUI.ShapeType) {
        self.border = border
        self.shape = shape
    }

    private func roundedRectangle(radius: AdaptyUI.CornerRadius) -> RoundedRectangle {
        if radius.isSameRadius {
            return RoundedRectangle(cornerRadius: radius.topLeft)
        } else {
            return RoundedRectangle(cornerRadius: 0.0)
        }
    }

    var body: some View {
        switch shape {
        case let .rectangle(cornerRadius):
            roundedRectangle(radius: cornerRadius)
                .strokeFilling(border.filling, lineWidth: border.thickness)
        case .circle:
            Circle()
                .strokeFilling(border.filling, lineWidth: border.thickness)
        case .curveUp:
            // TODO: implement
            Rectangle()
                .strokeFilling(border.filling, lineWidth: border.thickness)
        case .curveDown:
            // TODO: implement
            Rectangle()
                .strokeFilling(border.filling, lineWidth: border.thickness)
        }
    }
}

extension Shape {
    @ViewBuilder
    func fillBackground(_ background: AdaptyUI.Filling?) -> some View {
        if let background {
            switch background {
            case let .color(color):
                fill(color.swiftuiColor)
            case let .colorGradient(gradient):
                // TODO: check implementation
                fill(Color.clear)
                    .background(AdaptyUIGradient(gradient))
            case .image:
                // TODO: implement
                fill(Color.clear)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func strokeFilling(_ filling: AdaptyUI.Filling, lineWidth: CGFloat) -> some View {
        if let color = filling.asColor?.swiftuiColor {
            stroke(color, lineWidth: lineWidth)
        } else {
            self
        }
    }
}

extension View {
    @ViewBuilder
    func overlayBorder(_ border: AdaptyUI.Border?, shape: AdaptyUI.ShapeType) -> some View {
        if let border {
            overlay(AdaptyUIOverlayBorderView(border, shape: shape))
        } else {
            self
        }
    }
}

// TODO: check decoration option
// TODO: check inlinable
extension View {
    @ViewBuilder
    func applyingProperties(_ props: AdaptyUI.Element.Properties?) -> some View {
        frame(
            width: props?.frame?.width?.points(),
            height: props?.frame?.height?.points()
        )
        .frame(
            minWidth: props?.frame?.minWidth?.points(),
            maxWidth: props?.frame?.maxWidth?.points(),
            minHeight: props?.frame?.minHeight?.points(),
            maxHeight: props?.frame?.maxHeight?.points()
        )
        .offset(x: props?.offset.x ?? 0.0, y: props?.offset.y ?? 0.0)
        .backgroundDecorator(props?.decorator)
//        .background(props?.decorator?.background)
//        .border(props?.decorator?.border)
        .padding(props?.padding)
    }

    @ViewBuilder
    func padding(_ insets: AdaptyUI.EdgeInsets?) -> some View {
        if let insets {
            padding(.leading, insets.left)
                .padding(.top, insets.top)
                .padding(.trailing, insets.right)
                .padding(.bottom, insets.bottom)
        } else {
            self
        }
    }

    @ViewBuilder
    func backgroundDecorator(_ decorator: AdaptyUI.Decorator?) -> some View {
        if let decorator {
            background(
                AdaptyUIDecoratorView(decorator)
            )
        } else {
            self
        }
    }

    @ViewBuilder
    func background(_ filling: AdaptyUI.Filling?) -> some View {
        switch filling {
        case let .color(color):
            background(color.swiftuiColor)
        case let .colorGradient(gradient):
            background(AdaptyUIGradient(gradient))
        case let .image(imageData):
            self // TODO: implement
        case nil:
            self
        }
    }

    @ViewBuilder
    func border(_ border: AdaptyUI.Border?) -> some View {
        if let border, let color = border.filling.asColor?.swiftuiColor {
            self.border(color, width: border.thickness)
        } else {
            self
        }
    }
}

// TODO: move out
extension AdaptyUI.Color {
    var swiftuiColor: Color { Color(red: red, green: green, blue: blue, opacity: alpha) }
}

extension AdaptyUI.Unit {
    public func points(screenInPoints: CGFloat = 1024.0) -> CGFloat {
        switch self {
        case let .point(value): value
        case let .screen(value): value * screenInPoints
        }
    }
}

#if DEBUG
    @testable import Adapty

    extension AdaptyUI.Decorator {
        static var test: Self {
            .init(shapeType: .rectangle(cornerRadius: .init(same: 10)),
                  background: .color(.testGreen),
                  border: .init(filling: .color(.testRed), thickness: 2.0)
            )
        }
    }

    extension AdaptyUI.Element.Properties {
        static var test: Self {
            .init(
                decorator: .test,
                frame: nil,
                padding: .init(same: 12),
                offset: .zero,
                visibility: true,
                transitionIn: []
            )
        }
    }

    #Preview {
        AdaptyUIElementView(.text(.testBodyLong, .test))
//    AdaptyUIRichTextView(.testBodyLong)
//        .applyingProperties(.test)
    }
#endif
