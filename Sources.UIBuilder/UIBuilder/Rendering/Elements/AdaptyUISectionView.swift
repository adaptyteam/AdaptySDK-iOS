//
//  AdaptyUISectionView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import SwiftUI

extension VC.Section.Animation {
    var swiftUIAnimation: Animation {
        interpolator.createAnimation(duration: duration)
    }
}

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

    @State private var currentIndex: Int = 0

    var body: some View {
        let selectedIndexVariable = section.index

        let selectedIndex = stateViewModel.getValue(
            selectedIndexVariable,
            defaultValue: 0.0,
            screen: screen
        )

        let selectedIndexInt = Int(selectedIndex)

        Group {
            if let content = section.content[safe: currentIndex] {
                AdaptyUIElementView(
                    content,
                    screenHolderBuilder: {
                        if currentIndex == 0 {
                            screenHolderBuilder() // TODO: x check
                        } else {
                            EmptyView()
                        }
                    }
                )
            }
        }
        .onAppear {
            currentIndex = selectedIndexInt
        }
        .onChange(of: selectedIndexInt) { newIndex in
            if let animation = section.animation {
                withAnimation(animation.swiftUIAnimation) {
                    currentIndex = newIndex
                }
            } else {
                currentIndex = newIndex
            }
        }
    }
}

#endif
