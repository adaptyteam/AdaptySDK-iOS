//
//  UnevenRoundedRectangleFallback.swift
//
//
//  Created by Aleksey Goncharov on 22.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 13.0, *)
struct UnevenRoundedRectangleFallback: Shape {
    var cornerRadii: AdaptyUI.CornerRadius

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + cornerRadii.topLeading, y: rect.minY))

        // Top edge and top right corner
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadii.topTrailing, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadii.topTrailing, y: rect.minY + cornerRadii.topTrailing),
                    radius: cornerRadii.topTrailing,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)

        // Right edge and bottom right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadii.bottomTrailing))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadii.bottomTrailing, y: rect.maxY - cornerRadii.bottomTrailing),
                    radius: cornerRadii.bottomTrailing,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        // Bottom edge and bottom left corner
        path.addLine(to: CGPoint(x: rect.minX + cornerRadii.bottomLeading, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadii.bottomLeading, y: rect.maxY - cornerRadii.bottomLeading),
                    radius: cornerRadii.bottomLeading,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)

        // Left edge and top left corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadii.topLeading))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadii.topLeading, y: rect.minY + cornerRadii.topLeading),
                    radius: cornerRadii.topLeading,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)

        path.closeSubpath()
        return path
    }
}

@available(iOS 16.0, *)
extension AdaptyUI.CornerRadius {
    var systemRadii: RectangleCornerRadii {
        RectangleCornerRadii(
            topLeading: topLeading,
            bottomLeading: bottomLeading,
            bottomTrailing: bottomTrailing,
            topTrailing: topTrailing
        )
    }
}

#endif
