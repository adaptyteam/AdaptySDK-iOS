//
//  Shape+UIKit.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import Adapty
import UIKit

extension UIBezierPath {
    static func customRoundedRect(
        in bounds: CGRect,
        _ topLeftR: CGFloat,
        _ topRightR: CGFloat,
        _ bottomLeftR: CGFloat,
        _ bottomRightR: CGFloat
    ) -> UIBezierPath {
        let maskPath = UIBezierPath()
        let maxR = min(bounds.size.height / 2.0, bounds.size.width / 2.0)

        let topLeft = min(topLeftR, maxR)
        let topRight = min(topRightR, maxR)
        let bottomRight = min(bottomRightR, maxR)
        let bottomLeft = min(bottomLeftR, maxR)

        maskPath.move(to: CGPoint(x: bounds.minX + topLeft,
                                  y: bounds.minY))
        maskPath.addLine(to: CGPoint(x: bounds.maxX - topRight,
                                     y: bounds.minY))

        maskPath.addArc(withCenter: CGPoint(x: bounds.maxX - topRight,
                                            y: bounds.minY + topRight),
                        radius: topRight,
                        startAngle: .pi / 2.0,
                        endAngle: 0,
                        clockwise: true)

        maskPath.addLine(to: CGPoint(x: bounds.maxX,
                                     y: bounds.maxY - bottomRight))

        maskPath.addArc(withCenter: CGPoint(x: bounds.maxX - bottomRight,
                                            y: bounds.maxY - bottomRight),
                        radius: bottomRight,
                        startAngle: 0.0,
                        endAngle: .pi / 2.0,
                        clockwise: true)

        maskPath.addLine(to: CGPoint(x: bounds.minX + bottomLeft,
                                     y: bounds.maxY))

        maskPath.addArc(withCenter: CGPoint(x: bounds.minX + bottomLeft,
                                            y: bounds.maxY - bottomLeft),
                        radius: bottomLeft,
                        startAngle: 1.5 * .pi,
                        endAngle: .pi,
                        clockwise: true)

        maskPath.addLine(to: CGPoint(x: bounds.minX,
                                     y: bounds.minY + topLeft))

        maskPath.addArc(withCenter: CGPoint(x: bounds.minX + topLeft,
                                            y: bounds.minY + topLeft),
                        radius: topLeft,
                        startAngle: .pi,
                        endAngle: .pi / 2.0,
                        clockwise: true)

        maskPath.close()

        return maskPath
    }
}

extension CALayer {
    var maxCornerRadius: CGFloat { min(bounds.width, bounds.height) / 2.0 }

    func applyRectangleMask(radius: AdaptyUI.CornerRadius) {
        let maxRadius = maxCornerRadius

        if radius.isSameRadius {
            cornerRadius = min(radius.topLeft, maxRadius)
        } else {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath.customRoundedRect(
                in: bounds,
                min(radius.topLeft, maxRadius),
                min(radius.topRight, maxRadius),
                min(radius.bottomLeft, maxRadius),
                min(radius.bottomRight, maxRadius)
            ).cgPath
            
            mask = maskLayer
        }

        masksToBounds = true
    }

    func applyShapeMask(_ type: AdaptyUI.ShapeType?) {
        guard let type else {
            mask = nil
            masksToBounds = false
            return
        }

        switch type {
        case let .rectangle(radius):
            applyRectangleMask(radius: radius)
        case .circle:
            mask = CAShapeLayer.circleLayer(in: bounds)
            mask?.backgroundColor = UIColor.clear.cgColor
            masksToBounds = true
        default:
            break
        }
    }
}

extension CAShapeLayer {
    static func circleLayer(in rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor

        let radius = min(rect.height, rect.width) / 2.0

        layer.path = UIBezierPath(arcCenter: .init(x: rect.midX, y: rect.midY),
                                  radius: radius,
                                  startAngle: 0.0,
                                  endAngle: .pi * 2.0,
                                  clockwise: true).cgPath

        return layer
    }

    static func curveUpShapeLayer(in rect: CGRect, curveHeight: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor

        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + curveHeight))

        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + curveHeight),
                          controlPoint: CGPoint(x: rect.midX, y: rect.minY))

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        layer.path = path.cgPath

        return layer
    }

    static func curveDownShapeLayer(in rect: CGRect, curveHeight: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor

        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                          controlPoint: CGPoint(x: rect.midX, y: rect.minY + curveHeight))

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        layer.path = path.cgPath

        return layer
    }
}
