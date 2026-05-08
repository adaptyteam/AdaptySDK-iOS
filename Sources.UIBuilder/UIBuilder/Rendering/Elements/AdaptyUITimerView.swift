//
//  AdaptyUITimerView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUITimerView: View {
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @EnvironmentObject
    private var viewModel: AdaptyUITimerViewModel
    @EnvironmentObject
    private var customTagResolverViewModel: AdaptyUITagResolverViewModel
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    private var timer: VC.Timer

    init(_ timer: VC.Timer) {
        self.timer = timer
    }

    @State var timeLeft: TimeInterval = 0.0
    @State var text: VC.RichText?

    @ViewBuilder
    private var timerOrEmpty: some View {
        if let text {
            text
                .convertToSwiftUIText(
                    defaultAttributes: timer.format.textAttributes,
                    assetsCache: assetsViewModel.cache,
                    stateViewModel: stateViewModel,
                    tagValues: nil, // TODO: x check
                    internalTagResolver: { [timeLeft] tag in
                        tag == "TIMER" ? timeLeft : nil
                    },
                    customTagResolver: customTagResolverViewModel,
                    productInfo: nil,
                    colorScheme: colorScheme,
                    screen: screen
                )
                .multilineTextAlignment(timer.horizontalAlign)
                .lineLimit(timer.maxRows)
                .minimumScaleFactor(timer.overflowMode.contains(.scale) ? 0.1 : 1.0)
        } else {
            Text("")
        }
    }

    var body: some View {
        timerOrEmpty
            .onAppear {
                updateTime()
            }
            .onReceive(viewModel.objectWillChange) { _ in
                updateTime()
            }
    }

    private func updateTime() {
        let timeLeft = max(0.0, viewModel.timeLeft(
            for: timer,
            at: Date(),
            screen: screen
        ))

        text = timer.format.item(byValue: timeLeft)
        self.timeLeft = timeLeft
    }
}

#endif
