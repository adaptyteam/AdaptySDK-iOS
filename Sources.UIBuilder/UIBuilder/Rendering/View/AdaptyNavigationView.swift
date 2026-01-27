//
//  AdaptyNavigationView.swift
//  Adapty
//
//  Created by Alex Goncharov on 23/01/2026.
//

import SwiftUI

struct AdaptyNavigationView</* Header: View, */ Body: View /* , Footer: View */>: View {
    @ViewBuilder var screenBuilder: (ScreenUIInstance) -> Body
//    @ViewBuilder var headerBuilder: () -> Header
//    @ViewBuilder var footerBuilder: () -> Footer

    @EnvironmentObject
    private var screensViewModel: AdaptyUIScreensViewModel

//    @ViewBuilder
//    var popup: some View {
//        if let popupInstance = navigationManager.popupInstance {
//            ZStack {
//                Color.black.opacity(0.5)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        navigationManager.popupInstance = nil
//                    }
//
//                screenBuilder(popupInstance, navigationManager.getState(forScreenId: popupInstance.id))
//                    .cornerRadius(24.0)
//                    .frame(height: 400)
//                    .padding()
//            }
//        }
//    }

    var body: some View {
//        ZStack {
//            VStack(spacing: 0) {
//                headerBuilder()

        GeometryReader { geometry in
            ZStack {
                ForEach(screensViewModel.screensInstances) { screen in
                    screenBuilder(screen)
                        .offset(screen.offset)
                        .opacity(screen.opacity)
                        .zIndex(screen.zIndex)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                screensViewModel.setViewPortSize(geometry.size)
            }
            .onChange(of: geometry.size) {
                screensViewModel.setViewPortSize($0)
            }
        }
        .clipped()
//
//                footerBuilder()
//            }
//
//            popup
//        }
    }
}
