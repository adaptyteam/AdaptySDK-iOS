//
//  AdaptyUIBottomSheetView.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIBottomSheetView: View {
    @EnvironmentObject var viewModel: AdaptyScreensViewModel

    private let bottomSheet: AdaptyScreensViewModel.BottomSheet

    @State private var presented: Bool = false

    init(_ bottomSheet: AdaptyScreensViewModel.BottomSheet) {
        self.bottomSheet = bottomSheet
    }

    var body: some View {
        AdaptyUIElementView(bottomSheet.bottomSheet.content)
            .withScreenId(bottomSheet.id)
            .animation(.snappy.delay(0.1))
            .transition(.move(edge: .bottom))
    }
}

#endif
