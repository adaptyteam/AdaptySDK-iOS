//
//  AdaptyUIBoxView.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

extension AdaptyUI.Box {
    typealias Constraints = (min: CGFloat?, max: CGFloat?)

    static var emptyConstraints: Constraints { (min: nil, max: nil) }

    static func isEmptyConstraints(_ constraints: Constraints) -> Bool {
        switch constraints {
        case (nil, nil): true
        default: false
        }
    }
}

extension AdaptyUI.Box.Length {
    var constraints: AdaptyUI.Box.Constraints {
        switch self {
        case let .min(unit): (min: unit.points(), max: nil)
        case .fillMax: (min: nil, max: .infinity)
        default: (min: nil, max: nil)
        }
    }
}

@available(iOS 13.0, *)
extension View {
    @ViewBuilder
    func boxFixedFrameIfNeeded(
        width: AdaptyUI.Box.Length?,
        height: AdaptyUI.Box.Length?,
        alignment: Alignment
    ) -> some View {
        switch (width, height) {
        case let (.fixed(w), .fixed(h)):
            self.frame(width: w.points(),
                       height: h.points(),
                       alignment: alignment)
        case let (.fixed(w), _):
            self.frame(width: w.points(),
                       height: nil,
                       alignment: alignment)
        case let (_, .fixed(h)):
            self.frame(width: nil,
                       height: h.points(),
                       alignment: alignment)
        default:
            self
        }
    }

    @ViewBuilder
    func boxRangedFrameIfNeeded(
        width: AdaptyUI.Box.Length?,
        height: AdaptyUI.Box.Length?,
        alignment: Alignment
    ) -> some View {
        let wConstraints = width?.constraints ?? AdaptyUI.Box.emptyConstraints
        let hConstraints = height?.constraints ?? AdaptyUI.Box.emptyConstraints

        if AdaptyUI.Box.isEmptyConstraints(wConstraints) && AdaptyUI.Box.isEmptyConstraints(hConstraints) {
            self
        } else {
            self
                .frame(minWidth: wConstraints.min,
                       maxWidth: wConstraints.max,
                       minHeight: hConstraints.min,
                       maxHeight: hConstraints.max,
                       alignment: alignment)
        }
    }
}

@available(iOS 13.0, *)
struct AdaptyUIBoxView: View {
    var box: AdaptyUI.Box

    init(_ box: AdaptyUI.Box) {
        self.box = box
    }

    var body: some View {
        let alignment = Alignment.from(horizontal: self.box.horizontalAlignment,
                                       vertical: self.box.verticalAlignment)

        AdaptyUIElementView(self.box.content)
            .boxFixedFrameIfNeeded(
                width: self.box.width,
                height: self.box.heght,
                alignment: alignment
            )
            .boxRangedFrameIfNeeded(
                width: self.box.width,
                height: self.box.heght,
                alignment: alignment
            )
    }
}

#endif
