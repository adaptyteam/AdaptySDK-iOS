//
//  AdaptyUIToggleView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

extension AdaptyUI {
    struct ToggleMock {
        var color: Color?
        var sectionId: String = "toggle_test"
        var onIndex: Int = 0
        var offIndex: Int = -1
    }
}

@available(iOS 15.0, *)
struct AdaptyUIToggleView: View {
    @EnvironmentObject var viewModel: AdaptySectionsViewModel

    private var toggle: AdaptyUI.ToggleMock

    init(_ toggle: AdaptyUI.ToggleMock) {
        self.toggle = toggle
    }

    var body: some View {
        Toggle(isOn: .init(get: {
            // TODO: check default value
            (viewModel.selectedIndex(for: toggle.sectionId) ?? toggle.offIndex) == toggle.onIndex
        }, set: { value in
            viewModel.updateSelection(for: toggle.sectionId, index: value ? toggle.onIndex : toggle.offIndex)
        })) {
            EmptyView()
        }
        .tint(toggle.color?.swiftuiColor)
    }
}

#if DEBUG

@available(iOS 15.0, *)
#Preview {
    AdaptyUIToggleView(.init())
        .environmentObject(AdaptySectionsViewModel(logId: "Preview"))
}

#endif

#endif
