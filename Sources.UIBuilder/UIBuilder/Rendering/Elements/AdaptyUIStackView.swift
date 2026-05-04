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
                stackItems(usesFirstElementOnly: false)
            }
        case .horizontal:
            HStack(alignment: stack.verticalAlignment.swiftuiValue, spacing: stack.spacing) {
                stackItems(usesFirstElementOnly: true)
            }
        case .z:
            ZStack(
                alignment: .from(
                    horizontal: stack.horizontalAlignment.swiftuiValue(with: layoutDirection),
                    vertical: stack.verticalAlignment.swiftuiValue
                )
            ) {
                stackItems(usesFirstElementOnly: true)
            }
        }
    }

    @ViewBuilder
    private func stackItems(usesFirstElementOnly: Bool) -> some View {
        ForEach(0 ..< stack.items.count, id: \.self) { idx in
            switch stack.items[idx] {
            case let .space(count):
                if count > 0 {
                    ForEach(0 ..< count, id: \.self) { _ in
                        Spacer()
                    }
                }
            case let .element(element):
                AdaptyUIElementView(
                    element,
                    screenHolderBuilder: {
// Wrong: this gates screenHolder by stack item position.
// screenHolder must be consumed once on first actual encounter in the tree,
// then all subsequent screenHolders should become EmptyView().
//                        if idx == 0 {
                            screenHolderBuilder() // TODO: x check
//                        } else {
//                            EmptyView()
//                        }
                    }
                )
            }
        }
    }
}

#endif
