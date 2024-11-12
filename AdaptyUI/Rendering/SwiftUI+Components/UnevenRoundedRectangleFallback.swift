//
//  UnevenRoundedRectangleFallback.swift
//
//
//  Created by Aleksey Goncharov on 22.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUICore.CornerRadius {
    func normalized(width: Double, height: Double) -> AdaptyUICore.CornerRadius {
        var normalizedRadii = self

        // Normalize the top and bottom radii against the width
        let topSum = topLeading + topTrailing
        let bottomSum = bottomLeading + bottomTrailing

        if topSum > width {
            let scaleFactor = width / topSum
            normalizedRadii = AdaptyUICore.CornerRadius(
                topLeading: topLeading * scaleFactor,
                topTrailing: topTrailing * scaleFactor,
                bottomTrailing: bottomTrailing,
                bottomLeading: bottomLeading
            )
        }

        if bottomSum > width {
            let scaleFactor = width / bottomSum
            normalizedRadii = AdaptyUICore.CornerRadius(
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
            normalizedRadii = AdaptyUICore.CornerRadius(
                topLeading: normalizedRadii.topLeading * scaleFactor,
                topTrailing: normalizedRadii.topTrailing,
                bottomTrailing: normalizedRadii.bottomTrailing,
                bottomLeading: normalizedRadii.bottomLeading * scaleFactor
            )
        }

        if rightSum > height {
            let scaleFactor = height / rightSum
            normalizedRadii = AdaptyUICore.CornerRadius(
                topLeading: normalizedRadii.topLeading,
                topTrailing: normalizedRadii.topTrailing * scaleFactor,
                bottomTrailing: normalizedRadii.bottomTrailing * scaleFactor,
                bottomLeading: normalizedRadii.bottomLeading
            )
        }

        return normalizedRadii
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct UnevenRoundedRectangleFallback: InsettableShape {
    var cornerRadii: AdaptyUICore.CornerRadius
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> UnevenRoundedRectangleFallback {
        var shape = self
        shape.insetAmount += amount
        return shape
    }

    func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)

        let normalizedRadii = cornerRadii.normalized(width: insetRect.width, height: insetRect.height)

        let topLeading = normalizedRadii.topLeading
        let topTrailing = normalizedRadii.topTrailing
        let bottomTrailing = normalizedRadii.bottomTrailing
        let bottomLeading = normalizedRadii.bottomLeading

        var path = Path()

        path.move(to: CGPoint(x: insetRect.minX + topLeading, y: insetRect.minY))

        // Top edge and top right corner
        path.addLine(to: CGPoint(x: insetRect.maxX - topTrailing, y: insetRect.minY))
        path.addArc(
            center: CGPoint(x: insetRect.maxX - topTrailing, y: insetRect.minY + topTrailing),
            radius: topTrailing,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        // Right edge and bottom right corner
        path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY - bottomTrailing))
        path.addArc(
            center: CGPoint(x: insetRect.maxX - bottomTrailing, y: insetRect.maxY - bottomTrailing),
            radius: bottomTrailing,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge and bottom left corner
        path.addLine(to: CGPoint(x: insetRect.minX + bottomLeading, y: insetRect.maxY))
        path.addArc(
            center: CGPoint(x: insetRect.minX + bottomLeading, y: insetRect.maxY - bottomLeading),
            radius: bottomLeading,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // Left edge and top left corner
        path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.minY + topLeading))
        path.addArc(
            center: CGPoint(x: insetRect.minX + topLeading, y: insetRect.minY + topLeading),
            radius: topLeading,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension AdaptyUICore.CornerRadius {
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
