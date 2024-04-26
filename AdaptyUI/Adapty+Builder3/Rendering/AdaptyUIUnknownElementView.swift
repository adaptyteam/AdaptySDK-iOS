//
//  AdaptyUIUnknownElementView.swift
//
//
//  Created by Aleksey Goncharov on 3.4.24..
//

import Adapty
import SwiftUI

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

extension AdaptyUI.Element {
    var testCircle: Self {
        .unknown("circle", nil)
    }

    var testRectangle: Self {
        .unknown("rectangle", nil)
    }
}

#Preview {
    AdaptyUIUnknownElementView(value: AdaptyUI.DebugElement.rectangle.rawValue)
}
