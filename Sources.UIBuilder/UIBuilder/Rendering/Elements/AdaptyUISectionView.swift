//
//  AdaptyUISectionView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUISectionView<ScreenHolderContent: View>: View {
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    private let section: VC.Section
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ section: VC.Section,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.section = section
        self.screenHolderBuilder = screenHolderBuilder
    }

    var body: some View {
        let selectedIndexVariable = section.index
        
        let selectedIndex = stateViewModel.getValue(
            selectedIndexVariable,
            defaultValue: 0.0,
            screen: screen
        )
        
        let selectedIndexInt = Int(selectedIndex)
        
        if let content = section.content[safe: selectedIndexInt] {
            AdaptyUIElementView(
                content,
                screenHolderBuilder: {
                    if selectedIndexInt == 0 {
                        screenHolderBuilder() // TODO: x check
                    } else {
                        EmptyView()
                    }
                }
            )
        }
    }
}

#endif
