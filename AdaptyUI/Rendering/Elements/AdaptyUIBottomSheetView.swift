//
//  AdaptyUIBottomSheetView.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUIBottomSheetView: View {
    @EnvironmentObject var viewModel: AdaptyScreensViewModel

    private let bottomSheet: AdaptyScreensViewModel.BottomSheet

    @State private var presented: Bool = false

    init(_ bottomSheet: AdaptyScreensViewModel.BottomSheet) {
        self.bottomSheet = bottomSheet
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(presented ? 0.4 : 0.0)
                .onTapGesture {
                    withAnimation {
                        viewModel.dismissScreen(id: bottomSheet.id)
                    }
                }

            AdaptyUIElementView(bottomSheet.bottomSheet.content)
                .withScreenId(bottomSheet.id)
        }
        .ignoresSafeArea()
        .animation(.default.delay(0.3), value: presented)
        .animation(.snappy.delay(0.1))
        .transition(
            .move(edge: .bottom)
        )
        .onAppear {
            withAnimation {
                presented = true
            }

            viewModel.addDismissListener(id: bottomSheet.id) {
                withAnimation {
                    presented = false
                }
            }
        }
        .onDisappear {
            viewModel.removeDismissListener(id: bottomSheet.id)
        }
    }
}

#endif
