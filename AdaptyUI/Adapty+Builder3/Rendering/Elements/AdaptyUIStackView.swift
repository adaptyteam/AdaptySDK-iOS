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
struct AdaptyUIStackView: View {
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    private var stack: AdaptyUI.Stack

    init(_ stack: AdaptyUI.Stack) {
        self.stack = stack
    }

    var body: some View {
        switch stack.type {
        case .vertical:
            VStack(alignment: stack.horizontalAlignment.swiftuiValue(with: layoutDirection),
                   spacing: stack.spacing)
            {
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
            ZStack(
                alignment: .from(
                    horizontal: stack.horizontalAlignment.swiftuiValue(with: layoutDirection),
                    vertical: stack.verticalAlignment.swiftuiValue
                )
            ) {
                ForEach(0 ..< stack.content.count, id: \.self) {
                    AdaptyUIElementView(stack.content[$0])
                }
            }
        }
    }
}

#if DEBUG

@available(iOS 15.0, *)
#Preview {
    AdaptyUIStackView(
        .create(
            type: .vertical,
            horizontalAlignment: .trailing,
            content: [
                .text(.testTitle, nil),
                .box(.testCircleDog, nil)
//                .text(.testTitle, nil),
            ]
        )
    )
    .environmentObject(AdaptyProductsViewModel(logId: "Preview"))
    .environmentObject(AdaptyUIActionsViewModel(logId: "Preview"))
    .environmentObject(AdaptySectionsViewModel(logId: "Preview"))
    .environmentObject(AdaptyTagResolverViewModel(tagResolver: ["TEST_TAG": "Adapty"]))
    .environment(\.layoutDirection, .rightToLeft)
}
#endif

#endif
