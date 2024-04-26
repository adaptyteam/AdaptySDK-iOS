//
//  AdaptyUIButtonView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

extension AdaptyUI.Button: View {
    var currentStateView: AdaptyUI.Element? {
        if isSelected {
            selectedState ?? normalState
        } else {
            normalState
        }
    }

    public var body: some View {
        Button {
        } label: {
            if let currentStateView {
                AdaptyUIElementView(currentStateView)
            } else {
                EmptyView()
            }
        }
    }
}
