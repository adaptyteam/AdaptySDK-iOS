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

    /// `nil` until the section appears: the first pass renders the selected branch
    /// directly instead of building branch 0 and swapping it out in `onAppear`.
    @State private var currentIndex: Int?

    var body: some View {
        let selectedIndexVariable = section.index

        let selectedIndex = stateViewModel.getValue(
            selectedIndexVariable,
            defaultValue: 0.0,
            screen: screen
        )

        let selectedIndexInt = Int(selectedIndex)

        Group {
            if let content = section.content[safe: currentIndex ?? selectedIndexInt] {
                AdaptyUIElementView(
                    content,
                    screenHolderBuilder: screenHolderBuilder
                )
            }
        }
        .onAppear {
            currentIndex = selectedIndexInt
        }
        .onChange(of: selectedIndexInt) { newIndex in
            if let transition = section.transition {
                withAnimation(transition.swiftUIAnimation) {
                    currentIndex = newIndex
                }
            } else {
                currentIndex = newIndex
            }
        }
    }
}

#endif
