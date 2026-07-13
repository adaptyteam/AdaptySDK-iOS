//
//  ElementInteractionEnabledModifier.swift
//
//
//  Created by Aleksey Goncharov on 24.03.2026.
//

#if canImport(UIKit)

import SwiftUI

struct ElementInteractionEnabledModifier: ViewModifier {
    private let variable: VC.Variable?

    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel

    init(_ variable: VC.Variable?) {
        self.variable = variable
    }

    func body(content: Content) -> some View {
        if let variable {
            content
                .disabled(
                    !stateViewModel.getValue(
                        variable,
                        defaultValue: true,
                        screen: screen
                    )
                )
        } else {
            content
        }
    }
}

#endif
