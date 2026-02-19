//
//  AdaptyUIButtonView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIButtonView: View {
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    private var button: VC.Button

    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel

    init(_ button: VC.Button) {
        self.button = button
    }

    private var currentStateView: VC.Element {
        guard let isSelectedVariable = button.isSelectedState,
              stateViewModel.getValue(
                  isSelectedVariable,
                  defaultValue: false,
                  screen: screen
              )
        else {
            return button.normalState
        }

        return button.selectedState ?? button.normalState
    }

    var body: some View {
        Button {
            stateViewModel.execute(
                actions: button.actions,
                screen: screen
            )
        } label: {
            AdaptyUIElementView(
                currentStateView,
                screenHolderBuilder: {
                    EmptyView() // TODO: x check if is ok
                }
            )
        }
        .buttonStyle(.plain)
    }
}

#endif
