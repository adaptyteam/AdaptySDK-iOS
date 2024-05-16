//
//  AdaptyUIBoxView.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 13.0, *)
fileprivate extension View {
    @ViewBuilder
    func fixedFrameIfNeeded(box: AdaptyUI.Box) -> some View {
        let alignment = Alignment.from(horizontal: box.horizontalAlignment,
                                       vertical: box.verticalAlignment)

        switch (box.width, box.height) {
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

    func rangedFrameIfNeeded(box: AdaptyUI.Box) -> some View {
        func constraints(for lenght: AdaptyUI.Box.Length?) -> (CGFloat?, CGFloat?) {
            switch lenght {
            case let .min(unit): (unit.points(), nil)
            case .fillMax: (nil, .infinity)
            default: (nil, nil)
            }
        }

        @ViewBuilder
        func selfORFrame(_ wConstraints: (CGFloat?, CGFloat?),
                         _ hConstraints: (CGFloat?, CGFloat?)) -> some View
        {
            if wConstraints.0 == nil &&
                wConstraints.1 == nil &&
                hConstraints.0 == nil &&
                hConstraints.1 == nil
            {
                self
            } else {
                self
                    .frame(
                        minWidth: wConstraints.0,
                        maxWidth: wConstraints.1,
                        minHeight: hConstraints.0,
                        maxHeight: hConstraints.1,
                        alignment: .from(horizontal: box.horizontalAlignment,
                                         vertical: box.verticalAlignment)
                    )
            }
        }

        return selfORFrame(constraints(for: box.width),
                           constraints(for: box.height))
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
            .fixedFrameIfNeeded(box: self.box)
            .rangedFrameIfNeeded(box: self.box)
    }
}

#endif

#if DEBUG && canImport(UIKit)
@testable import Adapty

@available(iOS 13.0, *)
extension AdaptyUI.Decorator {
    static var greenBG: Self {
        .init(shapeType: .rectangle(cornerRadius: .zero),
              background: .color(.testGreen),
              border: nil)
    }
}

@available(iOS 13.0, *)
extension AdaptyUI.Element.Properties {
    static var greenBG: Self {
        .init(decorator: .greenBG,
              padding: .zero,
              offset: .zero,
              visibility: true,
              transitionIn: [])
    }
}

@available(iOS 13.0, *)
extension AdaptyUI.Box {
    static var test: Self {
        .init(width: .fillMax,
              height: .min(.point(48)),
              horizontalAlignment: .right,
              verticalAlignment: .center,
              content: .text(.testBodyShort, nil))
    }
}

@available(iOS 13.0, *)
#Preview {
    AdaptyUIElementView(.box(.test, .greenBG))
}

#endif
