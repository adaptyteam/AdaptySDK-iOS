//
//  AdaptyUISectionView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUISectionView: View {
    @EnvironmentObject var viewModel: AdaptyUISectionsViewModel

    var section: VC.Section

    init(_ section: VC.Section) {
        self.section = section
    }

    var body: some View {
        let index = viewModel.selectedIndex(for: section)

        if let content = section.content[safe: Int(index)] {
            AdaptyUIElementView(content)
        }
    }
}

#endif
