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
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject
    private var tagResolverViewModel: AdaptyUITagResolverViewModel

    @Environment(\.adaptyShowsDebugPlaceholders)
    private var showsDebugPlaceholders: Bool

    /// The host app's direction: the safe-area insets were read in it (`AdaptyUIPaywallView_Internal`).
    @Environment(\.layoutDirection)
    private var hostLayoutDirection: LayoutDirection
    @Environment(\.adaptySafeAreaInsets)
    private var hostSafeArea: EdgeInsets

    /// The insets in the flow's direction: leading and trailing swap when the flow and the host
    /// disagree, so a side inset stays on its physical side.
    private var flowSafeArea: EdgeInsets {
        guard screensViewModel.isRightToLeft != (hostLayoutDirection == .rightToLeft) else { return hostSafeArea }
        return EdgeInsets(
            top: hostSafeArea.top,
            leading: hostSafeArea.trailing,
            bottom: hostSafeArea.bottom,
            trailing: hostSafeArea.leading
        )
    }

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
            .withSafeArea(flowSafeArea)
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

    /// The whole localized string for `stringId` with every tag substituted and
    /// the attributes dropped, since a system alert shows plain text only.
    /// `text` when the id is absent, not localized, or neither the string nor
    /// its fallback resolves.
    private func text(_ value: VS.StringIdentifierOrText?) -> String? {
        guard let value else { return nil }
        guard let stringId = value.stringId else { return value.text }
        // A script may show an alert before any screen is open; a plain string id needs no screen.
        let screen = screensViewModel.topmostScreenInstance ?? AdaptyUIScreenInstanceKey.defaultValue

        if let text = assetsViewModel.plainText(
            stringId,
            screen: screen,
            stateViewModel: stateViewModel,
            customTagResolver: tagResolverViewModel,
            showsDebugPlaceholders: showsDebugPlaceholders
        ) { return text }

        Log.viewState.error("string_id \(stringId) is not localized or does not resolve")
        return value.text
    }
}
#endif
