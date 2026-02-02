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
    private var viewModel: AdaptyUISectionsViewModel

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
        let index = viewModel.selectedIndex(for: section)

        if let content = section.content[safe: Int(index)] {
            AdaptyUIElementView(
                content,
                screenHolderBuilder: {
                    if index == 0 {
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
