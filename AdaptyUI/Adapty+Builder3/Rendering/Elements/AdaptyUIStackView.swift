//
//  AdaptyUIStackView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 13.0, *)
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

@available(iOS 13.0, *)
extension AdaptyUI.Stack {
    var alignment: Alignment {
        Alignment.from(
            horizontal: horizontalAlignment,
            vertical: verticalAlignment
        )
    }
}

@available(iOS 13.0, *)
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

@available(iOS 13.0, *)
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

@available(iOS 13.0, *)
extension View {
    @ViewBuilder
    func fixedVerticalSizeIfFill(_ alignment: AdaptyUI.VerticalAlignment) -> some View {
        if alignment == .justified {
            fixedSize(horizontal: false, vertical: true)
        } else {
            self
        }
    }

    @ViewBuilder
    func fixedHorizontalSizeIfFill(_ alignment: AdaptyUI.HorizontalAlignment) -> some View {
        if alignment == .justified {
            fixedSize(horizontal: true, vertical: false)
        } else {
            self
        }
    }

    @ViewBuilder
    func infiniteHeightIfFill(_ alignment: AdaptyUI.VerticalAlignment) -> some View {
        if alignment == .justified {
            frame(maxHeight: .infinity)
        } else {
            self
        }
    }

    @ViewBuilder
    func infiniteWidthIfFill(_ alignment: AdaptyUI.HorizontalAlignment) -> some View {
        if alignment == .justified {
            frame(maxWidth: .infinity)
        } else {
            self
        }
    }
}

@available(iOS 13.0, *)
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
//                        .infiniteWidthIfFill(stack.horizontalAlignment)
                }
            }
        // TODO: inspect this
//            .fixedHorizontalSizeIfFill(stack.horizontalAlignment)
        case .horizontal:
            HStack(alignment: stack.verticalAlignment.swiftuiValue, spacing: stack.spacing) {
                ForEach(0 ..< stack.content.count, id: \.self) {
                    AdaptyUIElementView(stack.content[$0])
//                        .infiniteHeightIfFill(stack.verticalAlignment)
                }
            }
        // TODO: inspect this
//            .fixedVerticalSizeIfFill(stack.verticalAlignment)
        case .z:
            // TODO: implement fill-fill scenario
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

//    @available(iOS 13.0, *)
//    extension AdaptyUI.Frame {
//        static func fixed(width: Double, height: Double) -> Self {
//            .init(
//                height: .point(height),
//                width: .point(width),
//                minHeight: nil,
//                maxHeight: nil,
//                minWidth: nil,
//                maxWidth: nil
//            )
//        }
//    }

@available(iOS 13.0, *)
extension AdaptyUI.Stack {
    static var testHStack: AdaptyUI.Stack {
        AdaptyUI.Stack(
            type: .horizontal,
            horizontalAlignment: .left,
            verticalAlignment: .center,
            spacing: 0,
            content: [
                .button(
                    .init(
                        action: .close,
                        isSelected: false,
                        normalState: .text(
                            .testBodyLong,
                            .init(
                                decorator: .init(
                                    shapeType: .rectangle(cornerRadius: .zero),
                                    background: .color(.testGreen),
                                    border: nil
                                ),
                                padding: .zero,
                                offset: .zero,
                                visibility: true,
                                transitionIn: []
                            )
                        ),
                        selectedState: nil
                    ),
                    nil
                ),
                .space(1),
                .text(.testBodyShort, nil),
                .space(1),
                .text(
                    .testBodyLong,
                    .init(
                        decorator: .init(
                            shapeType: .rectangle(cornerRadius: .zero),
                            background: .color(.testGreen),
                            border: nil
                        ),
                        padding: .zero,
                        offset: .zero,
                        visibility: true,
                        transitionIn: []
                    )
                ),
            ]
        )
    }

    static var testZStack: AdaptyUI.Stack {
        AdaptyUI.Stack(
            type: .z,
            horizontalAlignment: .right,
            verticalAlignment: .top,
            spacing: 0,
            content: [
                .text(
                    .testBodyLong,
                    .init(
                        decorator: .init(
                            shapeType: .rectangle(cornerRadius: .zero),
                            background: .color(.testGreen),
                            border: nil
                        ),
                        padding: .zero,
                        offset: .zero,
                        visibility: true,
                        transitionIn: []
                    )
                ),
                .unknown("circle",
                         .init(
                             decorator: nil,
//                                 frame: .fixed(width: 32, height: 32),
                             padding: .zero,
                             offset: .init(x: 20, y: -20),
                             visibility: true,
                             transitionIn: []
                         )),
            ]
        )
    }

    static var testZStackMykola: AdaptyUI.Stack {
        AdaptyUI.Stack(
            type: .z,
            horizontalAlignment: .left,
            verticalAlignment: .top,
            spacing: 0,
            content: [
                // Green Rect 128x128
                .unknown(
                    "rectangle_green",
                    .init(
                        decorator: .init(
                            shapeType: .rectangle(cornerRadius: .zero),
                            background: .color(.testClear),
                            border: nil
                        ),
//                            frame: .fixed(width: 128, height: 128),
                        padding: .zero,
                        offset: .zero,
                        visibility: true,
                        transitionIn: []
                    )
                ),
                // Red Circle 64x64
                .unknown("circle_red",
                         .init(
                             decorator: nil,
//                                 frame: .fixed(width: 64, height: 64),
                             padding: .zero,
                             offset: .zero,
                             visibility: true,
                             transitionIn: []
                         )),
            ]
        )
    }

    static var testVStack: AdaptyUI.Stack {
        AdaptyUI.Stack(
            type: .vertical,
            horizontalAlignment: .left,
            verticalAlignment: .center,
            spacing: 0,
            content: [
                //                .space(1),
                .text(.testBodyShort, nil),
                .text(
                    .testBodyShortAlignRight,
                    nil
//                        .init(decorator: nil, frame: .init(height: nil, width: nil, minHeight: nil, maxHeight: nil, minWidth: nil, maxWidth: .point(10000000)), padding: .zero, offset: .zero, visibility: true, transitionIn: [])
                ),
//                .text(.testBodyLong, nil),
//                .space(1),
                .space(1),
            ]
        )
    }

    static var testVStackBig: AdaptyUI.Stack {
        AdaptyUI.Stack(
            type: .vertical,
            horizontalAlignment: .left,
            verticalAlignment: .center,
            spacing: 0,
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
}

@available(iOS 13.0, *)
#Preview {
    AdaptyUIStackView(
        .testVStack
//            .init(
//                decorator: .init(
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
