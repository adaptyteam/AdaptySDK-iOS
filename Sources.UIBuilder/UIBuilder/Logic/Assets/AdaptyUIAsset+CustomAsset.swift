//
//  AdaptyUIAsset+CustomAsset.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 20/08/2026.
//

#if canImport(UIKit)

import SwiftUI

package extension VC.Color {
    var asCustomAsset: AdaptyUICustomAsset {
        .color(.swiftUIColor(resolvedColor))
    }
}

package extension VC.ColorGradient {
    // Mirrors `resolvedGradient`, so a gradient passed through the cross-platform
    // bridge is mapped exactly like the same gradient coming from the backend.
    var asCustomAsset: AdaptyUICustomAsset {
        switch kind {
        case .linear:
            .gradient(
                .linear(
                    gradient: .init(stops: stops),
                    startPoint: start.unitPoint,
                    endPoint: end.unitPoint
                )
            )
        case .conic:
            .gradient(
                .angular(
                    gradient: .init(stops: stops),
                    center: start.unitPoint,
                    angle: .degrees(360)
                )
            )
        case .radial:
            .gradient(
                .radial(
                    gradient: .init(stops: stops),
                    center: start.unitPoint,
                    startRadius: end.x,
                    endRadius: end.y
                )
            )
        }
    }
}

#endif
