//
//  AdaptyUIButtonView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 13.0, *)
struct AdaptyUIButtonView: View {
    private var button: AdaptyUI.Button

    @EnvironmentObject var actionResolver: AdaptyUIActionResolver

    init(_ button: AdaptyUI.Button) {
        self.button = button
    }

    private var currentStateView: AdaptyUI.Element? {
        if button.isSelected {
            return button.selectedState ?? button.normalState
        } else {
            return button.normalState
        }
    }

    public var body: some View {
        Button {
            if let action = button.action {
                actionResolver.actionOccured(action)
            }
        } label: {
            if let currentStateView {
                AdaptyUIElementView(currentStateView)
            } else {
                EmptyView()
            }
        }
    }
}

#endif
