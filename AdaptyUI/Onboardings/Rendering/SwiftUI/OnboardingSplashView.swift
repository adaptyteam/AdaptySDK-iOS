//
//  OnboardingSplashView.swift
//
//
//  Created by Aleksey Goncharov on 09.08.2024.
//

import SwiftUI

@MainActor
struct OnboardingSplashView<Splash: View>: View {
    private let id: String

    private let splashViewBuilder: () -> Splash
    private let onCloseAction: (OnboardingsCloseAction) -> Void
    private let onOpenPaywallAction: ((OnboardingsOpenPaywallAction) -> Void)?
    private let onCustomAction: ((OnboardingsCustomAction) -> Void)?
    private let onStateUpdatedAction: ((OnboardingsStateUpdatedAction) -> Void)?
    private let onAnalyticsEvent: ((OnboardingsAnalyticsEvent) -> Void)?
    private let onError: (Error) -> Void

    @State private var url: URL?
    @State private var isLoading = true

    init(
        id: String,
        splashViewBuilder: @escaping () -> Splash,
        onCloseAction: @escaping (OnboardingsCloseAction) -> Void,
        onOpenPaywallAction: ((OnboardingsOpenPaywallAction) -> Void)?,
        onCustomAction: ((OnboardingsCustomAction) -> Void)?,
        onStateUpdatedAction: ((OnboardingsStateUpdatedAction) -> Void)?,
        onAnalyticsEvent: ((OnboardingsAnalyticsEvent) -> Void)?,
        onError: @escaping (Error) -> Void
    ) {
        self.id = id
        self.splashViewBuilder = splashViewBuilder
        self.onCloseAction = onCloseAction
        self.onOpenPaywallAction = onOpenPaywallAction
        self.onCustomAction = onCustomAction
        self.onStateUpdatedAction = onStateUpdatedAction
        self.onAnalyticsEvent = onAnalyticsEvent
        self.onError = onError
    }

    @ViewBuilder
    private var zstackBody: some View {
        ZStack {
            if let url {
                OnboardingView(
                    url: url,
                    onFinishLoading: { _ in
                        withAnimation {
                            isLoading = false
                        }
                    },
                    onCloseAction: onCloseAction,
                    onOpenPaywallAction: onOpenPaywallAction,
                    onCustomAction: onCustomAction,
                    onStateUpdatedAction: onStateUpdatedAction,
                    onAnalyticsEvent: onAnalyticsEvent,
                    onError: onError
                )
                .zIndex(0)
            }

            if isLoading || url == nil {
                splashViewBuilder()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            Task {
                await loadURL()
            }
        }
    }

    public var body: some View {
        if #available(iOS 14.0, *) {
            zstackBody
                .ignoresSafeArea()
        } else {
            zstackBody
                .edgesIgnoringSafeArea(.all)
        }
    }

    private func loadURL() async {
        do {
            url = try await Onboardings.activated.configuration.onboardingUrl(onboardingId: id)
        } catch {
            onError(error)
        }
    }
}
