//
//  AdaptyUIStackView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
extension Alignment {
    static func from(
        horizontal: AdaptyUI.HorizontalAlignment,
        vertical: AdaptyUI.VerticalAlignment
    ) -> Alignment {
        switch (vertical, horizontal) {
        case (.top, .left): .topLeading
        case (.top, .center): .top
        case (.top, .right): .topTrailing
        case (.center, .left): .leading
        case (.center, .center): .center
        case (.center, .right): .trailing
        case (.bottom, .left): .bottomLeading
        case (.bottom, .center): .bottom
        case (.bottom, .right): .bottomTrailing
        default: .center
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Stack {
    var alignment: Alignment {
        Alignment.from(
            horizontal: horizontalAlignment,
            vertical: verticalAlignment
        )
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.HorizontalAlignment {
    var swiftuiValue: SwiftUI.HorizontalAlignment {
        switch self {
        case .left: .leading // TODO:
        case .right: .trailing // TODO:
        case .leading: .leading
        case .trailing: .trailing
        case .center: .center
        case .justified: .center
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.VerticalAlignment {
    var swiftuiValue: SwiftUI.VerticalAlignment {
        switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        case .justified: .center
        }
    }
}

@available(iOS 15.0, *)
struct AdaptyUIStackView: View {
    var stack: AdaptyUI.Stack

    init(_ stack: AdaptyUI.Stack) {
        self.stack = stack
    }

    var body: some View {
        switch stack.type {
        case .vertical:
            VStack(alignment: stack.horizontalAlignment.swiftuiValue, spacing: stack.spacing) {
                ForEach(0 ..< stack.content.count, id: \.self) {
                    AdaptyUIElementView(stack.content[$0])
                }
            }
        case .horizontal:
            HStack(alignment: stack.verticalAlignment.swiftuiValue, spacing: stack.spacing) {
                ForEach(0 ..< stack.content.count, id: \.self) {
                    AdaptyUIElementView(stack.content[$0])
                }
            }
        case .z:
            ZStack(alignment: stack.alignment) {
                ForEach(0 ..< stack.content.count, id: \.self) {
                    AdaptyUIElementView(stack.content[$0])
                }
            }
        }
    }
}

#if DEBUG
@testable import Adapty

//    @available(iOS 15.0, *)
//    extension AdaptyUI.Frame {
//        static func fixed(width: Double, height: Double) -> Self {
//            .create(
//                height: .point(height),
//                width: .point(width),
//                minHeight: nil,
//                maxHeight: nil,
//                minWidth: nil,
//                maxWidth: nil
//            )
//        }
//    }

@available(iOS 15.0, *)
extension AdaptyUI.Stack {
    static var testHStack: AdaptyUI.Stack {
        .create(
            type: .horizontal,
            horizontalAlignment: .left,
            content: [
                .button(
                    .create(
                        action: .close,
                        normalState: .text(
                            .testBodyLong,
                            .create(
                                decorator: .create(
                                    shapeType: .rectangle(cornerRadius: .zero),
                                    background: .color(.testGreen)
                                )
                            )
                        )
                    ),
                    nil
                ),
                .space(1),
                .text(.testBodyShort, nil),
                .space(1),
                .text(
                    .testBodyLong,
                    .create(
                        decorator: .create(
                            shapeType: .rectangle(cornerRadius: .zero),
                            background: .color(.testGreen)
                        )
                    )
                ),
            ]
        )
    }

    static var testZStack: AdaptyUI.Stack {
        .create(
            type: .z,
            horizontalAlignment: .right,
            verticalAlignment: .top,
            content: [
                .text(
                    .testBodyLong,
                    .create(
                        decorator: .create(
                            shapeType: .rectangle(cornerRadius: .zero),
                            background: .color(.testGreen)
                        )
                    )
                ),
                .unknown("circle",
                         .create(
                             offset: .create(x: 20, y: -20)
                         )),
            ]
        )
    }

    static var testZStackMykola: AdaptyUI.Stack {
        .create(
            type: .z,
            horizontalAlignment: .left,
            verticalAlignment: .top,
            content: [
                // Green Rect 128x128
                .unknown(
                    "rectangle_green",
                    .create(
                        decorator: .create(
                            shapeType: .rectangle(cornerRadius: .zero),
                            background: .color(.testClear)
                        )
                    )
                ),
                // Red Circle 64x64
                .unknown("circle_red",
                         .create()
                ),
            ]
        )
    }

    static var testVStack: AdaptyUI.Stack {
        .create(
            horizontalAlignment: .left,
            content: [
                //                .space(1),
                .text(.testBodyShort, nil),
                .text(
                    .testBodyShortAlignRight,
                    nil
//                        .create(decorator: nil, frame: .create(height: nil, width: nil, minHeight: nil, maxHeight: nil, minWidth: nil, maxWidth: .point(10000000)), padding: .zero, offset: .zero, visibility: true, transitionIn: [])
                ),
//                .text(.testBodyLong, nil),
//                .space(1),
                .space(1),
            ]
        )
    }

    static var testVStackBig: AdaptyUI.Stack {
        .create(
            horizontalAlignment: .left,
            content: [
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
            ]
        )
    }

    static var testVStackMediumAndDog: AdaptyUI.Stack {
        .create(
            horizontalAlignment: .left,
            content: [
                .box(.testCircleDog,
                     .create(
                        decorator: .create(shapeType: .circle),
                        padding: .create(bottom: 24)
                     )
                ),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
            ]
        )
    }

    static var testVStackBigAndDog: AdaptyUI.Stack {
        .create(
            horizontalAlignment: .left,
            content: [
                .box(.testCircleDog,
                     .create(
                        decorator: .create(shapeType: .circle), 
                        padding: .create(bottom: 24)
                     )
                ),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
                .text(.testBodyLong, nil),
            ]
        )
    }
}

@available(iOS 15.0, *)
#Preview {
    AdaptyUIStackView(
        .testVStack
//            .create(
//                decorator: .create(
//                    shapeType: .rectangle(cornerRadius: .zero),
//                    background: .color(.testBlue),
//                    border: nil
//                ),
//                frame: .fixed(width: 200, height: 200),
//                padding: .zero,
//                offset: .zero,
//                visibility: true,
//                transitionIn: []
//            )
    )
}
#endif

#endif
