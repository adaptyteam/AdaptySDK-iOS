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
        GeometryReader { p in
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.7)
                    .onTapGesture {
                        withAnimation {
//                            presented = false
                            viewModel.dismissScreen(id: bottomSheet.id)
                        }
                    }

                if presented {
                    AdaptyUIElementView(
                        bottomSheet.bottomSheet.content,
                        additionalPadding: EdgeInsets(top: 0,
                                                      leading: 0,
                                                      bottom: p.safeAreaInsets.bottom,
                                                      trailing: 0)
                    )
                    .transition(.asymmetric(insertion: .move(edge: .bottom),
                                            removal: .opacity))
//                    .transition(.move(edge: .bottom))
                }
            }
        }
        .ignoresSafeArea()
        .withScreenId(bottomSheet.id)
        .transition(.opacity)
        .onAppear {
            withAnimation {
                presented = true
            }
        }
    }
}

#endif
