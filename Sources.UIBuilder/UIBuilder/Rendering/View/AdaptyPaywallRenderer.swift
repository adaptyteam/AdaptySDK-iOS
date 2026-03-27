//
//  AdaptyUIPaywallRenderer.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import SwiftUI

extension VS.ShowAlertDialogParameters.ActionStyle {
    var buttonRole: ButtonRole? {
        switch self {
        case .default: nil
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
}

struct AdaptyUIPaywallRendererView: View {
    @EnvironmentObject
    private var paywallViewModel: AdaptyUIPaywallViewModel
    @EnvironmentObject
    private var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject
    private var screensViewModel: AdaptyUIScreensViewModel
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel

    private var alertIsPresented: Binding<Bool> {
        Binding(
            get: { stateViewModel.alertDialog != nil },
            set: { newValue in
                if !newValue {
                    stateViewModel.alertDialog = nil
                }
            }
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                ZStack {
                    ForEach(screensViewModel.navigatorsViewModels, id: \.id) { navigator in
                        AdaptyNavigatorView()
                            .environmentObject(navigator)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .clipped()
            .environment(
                \.layoutDirection,
                screensViewModel.isRightToLeft ? .rightToLeft : .leftToRight
            )

            if productsViewModel.purchaseInProgress || productsViewModel.restoreInProgress {
                AdaptyUILoaderView()
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            paywallViewModel.logShowPaywall()
        }
        .alert(
            stateViewModel.alertDialog?.params.title ?? "",
            isPresented: alertIsPresented,
            actions: {
                if let buttons = stateViewModel.alertDialog?.params.buttons, !buttons.isEmpty {
                    ForEach(buttons, id: \.self) { button in
                        Button(button.title ?? "", role: button.style.buttonRole) {
                            stateViewModel.onAlertDialogResponse?(
                                button.actionId,
                                screensViewModel.topmostScreenInstance
                            )
                        }
                    }
                }
            },
            message: {
                if let message = stateViewModel.alertDialog?.params.message {
                    Text(message)
                }
            }
        )
    }
}

#endif
