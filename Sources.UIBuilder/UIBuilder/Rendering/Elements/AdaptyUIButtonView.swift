//
//  AdaptyUIButtonView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import SwiftUI

/// Tracks whether the current touch turned into a drag, so that swiping a pager
/// whose page is a full-size button does not fire the button action on release.
/// A reference type keeps the flag out of the view state — mutating it must not
/// redraw the button content.
@MainActor
private final class TapGuard {
    static let slop: CGFloat = 10.0

    var didDrag = false
}

struct AdaptyUIButtonView: View {
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @State
    private var tapGuard = TapGuard()

    private var button: VC.Button

    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel

    init(_ button: VC.Button) {
        self.button = button
    }

    private var currentStateView: VC.ElementIndex {
        guard let isSelectedVariable = button.legacyIsSelected,
              stateViewModel.getValue(
                  isSelectedVariable,
                  defaultValue: false,
                  screen: screen
              )
        else {
            return button.content
        }

        return button.legacySelectedContent ?? button.content
    }

    var body: some View {
        Button {
            guard !tapGuard.didDrag else { return }

            stateViewModel.execute(
                actions: button.actions,
                screen: screen
            )
        } label: {
            AdaptyUIElementView(
                currentStateView,
                screenHolderBuilder: { EmptyView() }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0.0)
                .onChanged { value in
                    if value.translation == .zero {
                        tapGuard.didDrag = false // a new touch started
                    } else if abs(value.translation.width) >= TapGuard.slop
                        || abs(value.translation.height) >= TapGuard.slop
                    {
                        tapGuard.didDrag = true
                    }
                }
                .onEnded { _ in
                    Task { @MainActor in tapGuard.didDrag = false }
                }
        )
    }
}

#endif
