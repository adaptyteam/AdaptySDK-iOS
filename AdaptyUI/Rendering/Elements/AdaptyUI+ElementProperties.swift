//
//  AdaptyUI+ElementProperties.swift
//
//
//  Created by Aleksey Goncharov on 3.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Point {
    var unitPoint: UnitPoint { UnitPoint(x: x, y: y) }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func applyingProperties(_ props: VC.Element.Properties?, includeBackground: Bool) -> some View {
        decorate(with: props?.decorator, includeBackground: includeBackground)
            .offset(x: props?.offset.x ?? 0.0, y: props?.offset.y ?? 0.0)
            .padding(props?.padding)
    }
}

#endif
