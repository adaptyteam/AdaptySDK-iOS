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

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIFlowRendererView: View {
    @EnvironmentObject
    private var flowViewModel: AdaptyUIFlowViewModel
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

            if productsViewModel.purchaseInProgress, screensViewModel.showPurchaseLoader {
                AdaptyUILoaderView()
                    .transition(.opacity)
            } else if productsViewModel.restoreInProgress, screensViewModel.showRestoreLoader {
                AdaptyUILoaderView()
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            flowViewModel.logShowFlow()
        }
        .alert(
            text(stateViewModel.alertDialog?.params.title) ?? "",
            isPresented: alertIsPresented,
            actions: {
                if let buttons = stateViewModel.alertDialog?.params.buttons, !buttons.isEmpty {
                    ForEach(buttons.indices, id: \.self) { idx in
                        let button = buttons[idx]
                        Button(text(button.title) ?? "", role: button.style.buttonRole) {
                            stateViewModel.onAlertDialogResponse?(
                                button.actionId,
                                screensViewModel.topmostScreenInstance
                            )
                        }
                    }
                }
            },
            message: {
                if let message = text(stateViewModel.alertDialog?.params.message) {
                    Text(message)
                }
            }
        )
    }

    private func text(_ value: VS.StringIdentifierOrText?) -> String? {
        value.flatMap { stateViewModel.stateHolder.current.text($0) }
    }
}

// TODO: в UIState нет возможности ресолвить теги в строках, потому не верно заводить такую функцию внутрь UIState. Поэтому я ее перенес сюда - где она используется.
// TODO: функция сначало должна обработать возможность взять строку по stringId, text - является фаллбеком !
// TODO: richText(stringId)?.asString - нельзя использовать ( данный метод вообще используется для другого) - мы договаривались что будет братся вся rich строка , будут подставлятся все теги , игнорируются атрибуты цвета и других параметров что не совместими с AllertView

private extension VS {

    /// The localized string for `stringId`, or `text` when the id is absent or not localized.
    func text(_ value: VS.StringIdentifierOrText) -> String? {
        guard let stringId = value.stringId else { return value.text }
        if let text = try? richText(stringId)?.asString { return text }
        Log.viewState.error("string_id \(stringId) is not localized as plain text")
        return value.text
    }
}
#endif
