//
//  AdaptyUIUnknownElementView.swift
//
//
//  Created by Aleksey Goncharov on 3.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
extension AdaptyUI {
    enum DebugElement: String {
        case circle
        case circleRed = "circle_red"
        case circleGreen = "circle_green"
        case circleBlue = "circle_blue"
        case circleYellow = "circle_yellow"

        case rectangle
        case rectangleRed = "rectangle_red"
        case rectangleGreen = "rectangle_green"
        case rectangleBlue = "rectangle_blue"
        case rectangleYellow = "rectangle_yellow"

        var fillColor: SwiftUI.Color {
            switch self {
            case .circleRed, .rectangleRed: .red
            case .circleGreen, .rectangleGreen: .green
            case .circleBlue, .rectangleBlue: .blue
            case .circleYellow, .rectangleYellow: .yellow
            default: .black
            }
        }
    }
}

@available(macOS 10.15, iOS 13.0, *)
extension AdaptyUI.DebugElement: View {
    var body: some View {
        switch self {
        case .circle, .circleRed, .circleGreen, .circleBlue, .circleYellow: Circle()
            .fill(fillColor)
        default:
            Rectangle()
                .fill(fillColor)
        }
    }
}

@available(macOS 10.15, iOS 13.0, *)
struct AdaptyUIUnknownElementView: View {
    var value: String

//    @ViewBuilder
//    private func debugView(_ element: AdaptyUI.DebugElement) -> some View {
//        element.shape
//            .fill(element.fillColor)
//    }

    var body: some View {
        if let debugElement = AdaptyUI.DebugElement(rawValue: value) {
            debugElement
        } else {
            Text("Unknown View \(value)")
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Element {
    var testCircle: Self {
        .unknown("circle", nil)
    }

    var testRectangle: Self {
        .unknown("rectangle", nil)
    }
}

@available(macOS 10.15, iOS 13.0, *)
#Preview {
    AdaptyUIUnknownElementView(value: AdaptyUI.DebugElement.rectangle.rawValue)
}

#endif
