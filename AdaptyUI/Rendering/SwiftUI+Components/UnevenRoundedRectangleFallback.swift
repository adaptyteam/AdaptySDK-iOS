//
//  UnevenRoundedRectangleFallback.swift
//
//
//  Created by Aleksey Goncharov on 22.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
extension AdaptyUI.CornerRadius {
    func normalized(width: Double, height: Double) -> AdaptyUI.CornerRadius {
        var normalizedRadii = self

        // Normalize the top and bottom radii against the width
        let topSum = topLeading + topTrailing
        let bottomSum = bottomLeading + bottomTrailing

        if topSum > width {
            let scaleFactor = width / topSum
            normalizedRadii = AdaptyUI.CornerRadius(
                topLeading: topLeading * scaleFactor,
                topTrailing: topTrailing * scaleFactor,
                bottomTrailing: bottomTrailing,
                bottomLeading: bottomLeading
            )
        }

        if bottomSum > width {
            let scaleFactor = width / bottomSum
            normalizedRadii = AdaptyUI.CornerRadius(
                topLeading: normalizedRadii.topLeading,
                topTrailing: normalizedRadii.topTrailing,
                bottomTrailing: bottomTrailing * scaleFactor,
                bottomLeading: bottomLeading * scaleFactor
            )
        }

        // Normalize the left and right radii against the height
        let leftSum = topLeading + bottomLeading
        let rightSum = topTrailing + bottomTrailing

        if leftSum > height {
            let scaleFactor = height / leftSum
            normalizedRadii = AdaptyUI.CornerRadius(
                topLeading: normalizedRadii.topLeading * scaleFactor,
                topTrailing: normalizedRadii.topTrailing,
                bottomTrailing: normalizedRadii.bottomTrailing,
                bottomLeading: normalizedRadii.bottomLeading * scaleFactor
            )
        }

        if rightSum > height {
            let scaleFactor = height / rightSum
            normalizedRadii = AdaptyUI.CornerRadius(
                topLeading: normalizedRadii.topLeading,
                topTrailing: normalizedRadii.topTrailing * scaleFactor,
                bottomTrailing: normalizedRadii.bottomTrailing * scaleFactor,
                bottomLeading: normalizedRadii.bottomLeading
            )
        }

        return normalizedRadii
    }
}

@available(iOS 15.0, *)
struct UnevenRoundedRectangleFallback: InsettableShape {
    var cornerRadii: AdaptyUI.CornerRadius

    func inset(by amount: CGFloat) -> UnevenRoundedRectangleFallback {
        UnevenRoundedRectangleFallback(
            cornerRadii: .init(
                topLeading: cornerRadii.topLeading - amount,
                topTrailing: cornerRadii.topTrailing - amount,
                bottomTrailing: cornerRadii.bottomTrailing - amount,
                bottomLeading: cornerRadii.bottomLeading - amount
            )
        )
    }

    func path(in rect: CGRect) -> Path {
        let normalizedRadii = cornerRadii.normalized(width: rect.width, height: rect.height)

        let topLeading = normalizedRadii.topLeading // min(maxRadius, cornerRadii.topLeading)
        let topTrailing = normalizedRadii.topTrailing // min(maxRadius, cornerRadii.topTrailing)
        let bottomTrailing = normalizedRadii.bottomTrailing // min(maxRadius, cornerRadii.bottomTrailing)
        let bottomLeading = normalizedRadii.bottomLeading // min(maxRadius, cornerRadii.bottomLeading)

        var path = Path()

        path.move(to: CGPoint(x: rect.minX + topLeading, y: rect.minY))

        // Top edge and top right corner
        path.addLine(to: CGPoint(x: rect.maxX - topTrailing, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - topTrailing, y: rect.minY + topTrailing),
                    radius: topTrailing,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)

        // Right edge and bottom right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomTrailing))
        path.addArc(center: CGPoint(x: rect.maxX - bottomTrailing, y: rect.maxY - bottomTrailing),
                    radius: bottomTrailing,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        // Bottom edge and bottom left corner
        path.addLine(to: CGPoint(x: rect.minX + bottomLeading, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottomLeading, y: rect.maxY - bottomLeading),
                    radius: bottomLeading,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)

        // Left edge and top left corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeading))
        path.addArc(center: CGPoint(x: rect.minX + topLeading, y: rect.minY + topLeading),
                    radius: topLeading,
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
