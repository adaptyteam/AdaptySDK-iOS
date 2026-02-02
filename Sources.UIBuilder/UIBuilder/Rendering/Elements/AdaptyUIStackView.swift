//
//  AdaptyUIStackView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIStackView<ScreenHolderContent: View>: View {
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    private let stack: VC.Stack
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ stack: VC.Stack,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.stack = stack
        self.screenHolderBuilder = screenHolderBuilder
    }

    var body: some View {
        switch stack.type {
        case .vertical:
            VStack(alignment: stack.horizontalAlignment.swiftuiValue(with: layoutDirection),
                   spacing: stack.spacing)
            {
                ForEach(0 ..< stack.content.count, id: \.self) { idx in
                    AdaptyUIElementView(
                        stack.content[idx],
                        screenHolderBuilder: {
                            if idx == 0 {
                                screenHolderBuilder() // TODO: x check
                            } else {
                                EmptyView()
                            }
                        }
                    )
                }
            }
        case .horizontal:
            HStack(alignment: stack.verticalAlignment.swiftuiValue, spacing: stack.spacing) {
                ForEach(0 ..< stack.content.count, id: \.self) { idx in
                    AdaptyUIElementView(
                        stack.content[idx],
                        screenHolderBuilder: {
                            if idx == 0 {
                                screenHolderBuilder() // TODO: x check
                            } else {
                                EmptyView()
                            }
                        }
                    )
                }
            }
        case .z:
            ZStack(
                alignment: .from(
                    horizontal: stack.horizontalAlignment.swiftuiValue(with: layoutDirection),
                    vertical: stack.verticalAlignment.swiftuiValue
                )
            ) {
                ForEach(0 ..< stack.content.count, id: \.self) { idx in
                    AdaptyUIElementView(
                        stack.content[idx],
                        screenHolderBuilder: {
                            if idx == 0 {
                                screenHolderBuilder() // TODO: x check
                            } else {
                                EmptyView()
                            }
                        }
                    )
                }
            }
        }
    }
}

#endif
