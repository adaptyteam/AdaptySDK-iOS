//
//  AdaptyNavigationView.swift
//  Adapty
//
//  Created by Alex Goncharov on 23/01/2026.
//

import SwiftUI

private struct AdaptyNavigatorView<Body: View>: View {
    @ViewBuilder
    var screenBuilder: (AdaptyUIScreenInstance) -> Body

    @EnvironmentObject
    private var navigatorViewModel: AdaptyUINavigatorViewModel

    var body: some View {
        ForEach(navigatorViewModel.screens) { screen in
            screenBuilder(screen)
                .offset(screen.offset)
                .opacity(screen.opacity)
                .zIndex(navigatorViewModel.zIndexBase + screen.zIndex)
        }
        .onAppear {
            navigatorViewModel.reportOnAppear(
                ScreenTransitionAnimation.inAnimationBuilder(
                    transitionType: .directional,
                    transitionDirection: .bottomToTop,
                    transitionStyle: .move
                )
            )
        }
    }
}

struct AdaptyNavigationView<Body: View>: View {
    @ViewBuilder var screenBuilder: (AdaptyUIScreenInstance) -> Body

    @EnvironmentObject
    private var screensViewModel: AdaptyUIScreensViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(screensViewModel.navigators, id: \.id) { navigator in
                    AdaptyNavigatorView(
                        screenBuilder: screenBuilder
                    )
                    .environmentObject(navigator)
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
        .environment(
            \.layoutDirection,
            screensViewModel.isRightToLeft ? .rightToLeft : .leftToRight
        )
    }
}
