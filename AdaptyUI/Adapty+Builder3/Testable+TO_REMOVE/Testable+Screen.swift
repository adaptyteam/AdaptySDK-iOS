//
//  File.swift
//  
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if DEBUG

import Adapty
import Foundation

// @testable import Adapty

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
                         .create()),
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
                     )),
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
                     )),
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
extension AdaptyUI.Screen {
    static var testBasicDog: Self {
        .create(
            background: .color(.testWhite),
            cover: .box(.testBasicDog, nil),
            content: .stack(.testVStackBig, .blueBG),
            footer: .stack(.testHStack, .redBG)
        )
    }
    
    static var testFlatDog: Self {
        .create(
            background: .color(.testWhite),
            content: .stack(.testVStackBigAndDog, .blueBG),
            footer: .stack(.testHStack, .redBG),
            overlay: .text(.testBodyLong, nil)
        )
    }
    
    static var testTransparent: Self {
        .create(
            background: .color(.testWhite),
            content: .box(.testBasicDog, nil),
            footer: .stack(.testVStackMediumAndDog, .greenBG),
            overlay: .text(.testBodyShort, nil)
        )
    }
    
    static var testTransparentScroll: Self {
        .create(
            background: .color(.testWhite),
            content: .box(.testBasicDog, nil),
            footer: .stack(.testVStackBigAndDog, .greenBG),
            overlay: .text(.testBodyShort, nil)
        )
    }
}

#endif
