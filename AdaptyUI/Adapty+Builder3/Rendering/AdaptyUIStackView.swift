//
//  AdaptyUIStackView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

extension AdaptyUI.Stack {
    var alignment: Alignment {
        switch (verticalAlignment, horizontalAlignment) {
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

extension AdaptyUI.HorizontalAlignment {
    var swiftuiValue: SwiftUI.HorizontalAlignment {
        switch self {
        case .left: .leading
        case .center: .center
        case .right: .trailing
        case .fill: .center
        }
    }
}

extension AdaptyUI.VerticalAlignment {
    var swiftuiValue: SwiftUI.VerticalAlignment {
        switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        case .fill: .center
        }
    }
}

extension View {
    @ViewBuilder
    func fixedVerticalSizeIfFill(_ alignment: AdaptyUI.VerticalAlignment) -> some View {
        if alignment == .fill {
            fixedSize(horizontal: false, vertical: true)
        } else {
            self
        }
    }

    @ViewBuilder
    func fixedHorizontalSizeIfFill(_ alignment: AdaptyUI.HorizontalAlignment) -> some View {
        if alignment == .fill {
            fixedSize(horizontal: true, vertical: false)
        } else {
            self
        }
    }

    @ViewBuilder
    func infiniteHeightIfFill(_ alignment: AdaptyUI.VerticalAlignment) -> some View {
        if alignment == .fill {
            frame(maxHeight: .infinity)
        } else {
            self
        }
    }

    @ViewBuilder
    func infiniteWidthIfFill(_ alignment: AdaptyUI.HorizontalAlignment) -> some View {
        if alignment == .fill {
            frame(maxWidth: .infinity)
        } else {
            self
        }
    }
}

struct AdaptyUIStackView: View {
    var stack: AdaptyUI.Stack
    var properties: AdaptyUI.Element.Properties?

    init(_ stack: AdaptyUI.Stack,
         _ properties: AdaptyUI.Element.Properties?) {
        self.stack = stack
        self.properties = properties
    }

    var body: some View {
        switch stack.type {
        case .vertical:
            VStack(alignment: stack.horizontalAlignment.swiftuiValue, spacing: 0) {
                ForEach(0 ..< stack.elements.count, id: \.self) {
                    AdaptyUIElementView(stack.elements[$0])
                        .infiniteWidthIfFill(stack.horizontalAlignment)
                }
            }
            .fixedHorizontalSizeIfFill(stack.horizontalAlignment)
            .applyingProperties(properties)
        case .horizontal:
            HStack(alignment: stack.verticalAlignment.swiftuiValue, spacing: 0) {
                ForEach(0 ..< stack.elements.count, id: \.self) {
                    AdaptyUIElementView(stack.elements[$0])
                        .infiniteHeightIfFill(stack.verticalAlignment)
                }
            }
            .fixedVerticalSizeIfFill(stack.verticalAlignment)
            .applyingProperties(properties)
        case .z:
            // TODO: implement fill-fill scenario
            ZStack(alignment: stack.alignment) {
                ForEach(0 ..< stack.elements.count, id: \.self) {
                    AdaptyUIElementView(stack.elements[$0])
                }
            }
            .applyingProperties(properties)
        }
    }
}

#if DEBUG
    @testable import Adapty

    extension AdaptyUI.Frame {
        static func fixed(width: Double, height: Double) -> Self {
            .init(
                height: .point(height),
                width: .point(width),
                minHeight: nil,
                maxHeight: nil,
                minWidth: nil,
                maxWidth: nil
            )
        }
    }

    extension AdaptyUI.Stack {
        static var testHStack: AdaptyUI.Stack {
            AdaptyUI.Stack(
                type: .horizontal,
                horizontalAlignment: .left,
                verticalAlignment: .fill,
                elements: [
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
                                    frame: nil,
                                    padding: .zero,
                                    offset: .zero,
                                    visibility: true,
                                    transitionIn: []
                                )
                            ),
                            selectedState: nil),
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
                            frame: nil,
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
                elements: [
                    .text(
                        .testBodyLong,
                        .init(
                            decorator: .init(
                                shapeType: .rectangle(cornerRadius: .zero),
                                background: .color(.testGreen),
                                border: nil
                            ),
                            frame: nil,
                            padding: .zero,
                            offset: .zero,
                            visibility: true,
                            transitionIn: []
                        )
                    ),
                    .unknown("circle",
                             .init(
                                 decorator: nil,
                                 frame: .fixed(width: 32, height: 32),
                                 padding: .zero,
                                 offset: .init(x: 20, y: -20),
                                 visibility: true,
                                 transitionIn: []
                             )
                    ),
                ]
            )
        }

        static var testZStackMykola: AdaptyUI.Stack {
            AdaptyUI.Stack(
                type: .z,
                horizontalAlignment: .left,
                verticalAlignment: .top,
                elements: [
                    // Green Rect 128x128
                    .unknown(
                        "rectangle_green",
                        .init(
                            decorator: .init(
                                shapeType: .rectangle(cornerRadius: .zero),
                                background: .color(.testClear),
                                border: nil
                            ),
                            frame: .fixed(width: 128, height: 128),
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
                                 frame: .fixed(width: 64, height: 64),
                                 padding: .zero,
                                 offset: .zero,
                                 visibility: true,
                                 transitionIn: []
                             )
                    ),
                ]
            )
        }

        static var testVStack: AdaptyUI.Stack {
            AdaptyUI.Stack(
                type: .vertical,
                horizontalAlignment: .left,
                verticalAlignment: .center,
                elements: [
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
    }

    #Preview {
        AdaptyUIStackView(
            .testVStack,
            nil
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
