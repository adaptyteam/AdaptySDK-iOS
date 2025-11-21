//
//  AdaptyUIBottomSheetView.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension AdaptyUIBuilder {
    static var mainScreenBounds: CGRect {
#if os(visionOS)
        UIApplication.shared.windows.first?.bounds ?? .zero
#else
        UIScreen.main.bounds
#endif
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIBottomSheetView: View {
    @EnvironmentObject var viewModel: AdaptyUIBottomSheetViewModel

    @State private var offset: CGFloat = AdaptyUIBuilder.mainScreenBounds.height

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .frame(maxHeight: .infinity)

            AdaptyUIElementView(viewModel.bottomSheet.content)
                .withScreenId(viewModel.id)
                .offset(y: offset)
                .onAppear {
                    offset = viewModel.isPresented ? 0.0 : AdaptyUIBuilder.mainScreenBounds.height
                }
        }
        .ignoresSafeArea()
        .onChange(of: viewModel.isPresented) { newValue in
            withAnimation(newValue ? .easeOut : .linear) {
                offset = newValue ? 0.0 : AdaptyUIBuilder.mainScreenBounds.height
            }
        }
    }
}

#endif
