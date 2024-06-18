//
//  AdaptyUISectionView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUISectionView: View {
    @EnvironmentObject var viewModel: AdaptySectionsViewModel
    
    var section: AdaptyUI.Section

    init(_ section: AdaptyUI.Section) {
        self.section = section
    }

    var body: some View {
        let index = viewModel.selectedIndex(for: section)

        if let content = section.content[safe: index] {
            AdaptyUIElementView(content)
        }
    }
}

#endif
