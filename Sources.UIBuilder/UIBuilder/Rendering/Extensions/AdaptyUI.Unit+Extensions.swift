//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

#if canImport(UIKit)

import SwiftUI

package extension VC.Unit {
    func points(screenSize: Double, safeAreaStart: Double, safeAreaEnd: Double) -> Double {
        switch self {
        case let .point(value): value
        case let .screen(value): value * screenSize
        case let .safeArea(value):
            switch value {
            case .start: safeAreaStart
            case .end: safeAreaEnd
            }
        }
    }

    enum Direction {
        case horizontal
        case vertical
    }

    func points(
        _ direction: Direction,
        _ screenSize: CGSize,
        _ safeArea: EdgeInsets
    ) -> Double {
        switch direction {
        case .horizontal:
            points(
                screenSize: screenSize.width,
                safeAreaStart: safeArea.leading,
                safeAreaEnd: safeArea.trailing
            )
        case .vertical:
            points(
                screenSize: screenSize.height,
                safeAreaStart: safeArea.top,
                safeAreaEnd: safeArea.bottom
            )
        }
    }
}

#endif
