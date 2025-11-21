//
//  AdaptyUIBuilder+PaywallView.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 9/23/25.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyUIPaywallViewModifier<Placeholder>: ViewModifier where Placeholder: View {
    @Environment(\.presentationMode) private var presentationMode

    private let isPresented: Binding<Bool>
    private let fullScreen: Bool

    private let paywallConfiguration: AdaptyUIBuilder.PaywallConfiguration?

    private let didAppear: (() -> Void)?
    private let didDisappear: (() -> Void)?
    private let didPerformAction: ((AdaptyUIBuilder.Action) -> Void)?
    private let didSelectProduct: ((ProductResolver) -> Void)?
    private let didStartPurchase: ((ProductResolver) -> Void)?
    private let didStartRestore: (() -> Void)?
    private let didFailRendering: (AdaptyUIBuilderError) -> Void
    private let placeholderBuilder: () -> Placeholder

    init(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywallConfiguration: AdaptyUIBuilder.PaywallConfiguration?,
        didAppear: (() -> Void)? = nil,
        didDisappear: (() -> Void)? = nil,
        didPerformAction: ((AdaptyUIBuilder.Action) -> Void)?,
        didSelectProduct: ((ProductResolver) -> Void)?,
        didStartPurchase: ((ProductResolver) -> Void)?,
        didStartRestore: (() -> Void)?,
        didFailRendering: @escaping (AdaptyUIBuilderError) -> Void,
        placeholderBuilder: @escaping (() -> Placeholder)
    ) {
        self.isPresented = isPresented
        self.fullScreen = fullScreen
        self.paywallConfiguration = paywallConfiguration
        self.didAppear = didAppear
        self.didDisappear = didDisappear
        self.didPerformAction = didPerformAction
        self.didSelectProduct = didSelectProduct
        self.didStartPurchase = didStartPurchase
        self.didStartRestore = didStartRestore
        self.didFailRendering = didFailRendering
        self.placeholderBuilder = placeholderBuilder
    }

    @ViewBuilder
    private var paywallOrProgressView: some View {
        if let paywallConfiguration {
            AdaptyUIPaywallView(
                paywallConfiguration: paywallConfiguration,
                didAppear: didAppear,
                didDisappear: didDisappear,
                didPerformAction: didPerformAction,
                didSelectProduct: didSelectProduct,
                didStartPurchase: didStartPurchase,
                didStartRestore: didStartRestore,
                didFailRendering: didFailRendering
            )
        } else {
            placeholderBuilder()
        }
    }

    public func body(content: Content) -> some View {
        if fullScreen {
            content
                .fullScreenCover(
                    isPresented: isPresented,
                    onDismiss: {
                        paywallConfiguration?.reportOnDisappear()
                    },
                    content: {
                        paywallOrProgressView
                    }
                )
        } else {
            content
                .sheet(
                    isPresented: isPresented,
                    onDismiss: {
                        paywallConfiguration?.reportOnDisappear()
                    },
                    content: {
                        paywallOrProgressView
                    }
                )
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public extension View {
    func paywall<Placeholder: View>(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywallConfiguration: AdaptyUIBuilder.PaywallConfiguration?,
        didAppear: (() -> Void)? = nil,
        didDisappear: (() -> Void)? = nil,
        didPerformAction: ((AdaptyUIBuilder.Action) -> Void)? = nil,
        didSelectProduct: ((ProductResolver) -> Void)? = nil,
        didStartPurchase: ((ProductResolver) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFailRendering: @escaping (AdaptyUIBuilderError) -> Void,
        placeholderBuilder: @escaping (() -> Placeholder)
    ) -> some View {
        modifier(
            AdaptyUIPaywallViewModifier<Placeholder>(
                isPresented: isPresented,
                fullScreen: fullScreen,
                paywallConfiguration: paywallConfiguration,
                didAppear: didAppear,
                didDisappear: didDisappear,
                didPerformAction: didPerformAction,
                didSelectProduct: didSelectProduct,
                didStartPurchase: didStartPurchase,
                didStartRestore: didStartRestore,
                didFailRendering: didFailRendering,
                placeholderBuilder: placeholderBuilder
            )
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public struct AdaptyUIPaywallView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private let paywallConfiguration: AdaptyUIBuilder.PaywallConfiguration

    private let didAppear: (() -> Void)?
    private let didDisappear: (() -> Void)?
    private let didPerformAction: ((AdaptyUIBuilder.Action) -> Void)?
    private let didSelectProduct: ((ProductResolver) -> Void)?
    private let didStartPurchase: ((ProductResolver) -> Void)?
    private let didStartRestore: (() -> Void)?
    private let didFailRendering: ((AdaptyUIBuilderError) -> Void)?

    public init(
        paywallConfiguration: AdaptyUIBuilder.PaywallConfiguration,
        didAppear: (() -> Void)? = nil,
        didDisappear: (() -> Void)? = nil,
        didPerformAction: ((AdaptyUIBuilder.Action) -> Void)? = nil,
        didSelectProduct: ((ProductResolver) -> Void)? = nil,
        didStartPurchase: ((ProductResolver) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFailRendering: @escaping (AdaptyUIBuilderError) -> Void
    ) {
        self.paywallConfiguration = paywallConfiguration
        self.didAppear = didAppear
        self.didDisappear = didDisappear
        self.didPerformAction = didPerformAction
        self.didSelectProduct = didSelectProduct
        self.didStartPurchase = didStartPurchase
        self.didStartRestore = didStartRestore
        self.didFailRendering = didFailRendering
    }

    public var body: some View {
        paywallConfiguration.eventsHandler.didAppear = didAppear
        paywallConfiguration.eventsHandler.didDisappear = didDisappear

        paywallConfiguration.eventsHandler.didPerformAction = didPerformAction ?? { action in
            switch action {
            case .close:
                presentationMode.wrappedValue.dismiss()
            case let .openURL(url):
                UIApplication.shared.open(url, options: [:])
            case .custom:
                break
            }
        }

        paywallConfiguration.eventsHandler.didSelectProduct = didSelectProduct ?? { _ in }
        paywallConfiguration.eventsHandler.didStartPurchase = didStartPurchase ?? { _ in }

        paywallConfiguration.eventsHandler.didStartRestore = didStartRestore ?? {}
        paywallConfiguration.eventsHandler.didFailRendering = didFailRendering

        return AdaptyUIPaywallView_Internal(
            showDebugOverlay: false
        )
        .environmentObject(paywallConfiguration.eventsHandler)
        .environmentObject(paywallConfiguration.paywallViewModel)
        .environmentObject(paywallConfiguration.productsViewModel)
        .environmentObject(paywallConfiguration.actionsViewModel)
        .environmentObject(paywallConfiguration.sectionsViewModel)
        .environmentObject(paywallConfiguration.tagResolverViewModel)
        .environmentObject(paywallConfiguration.timerViewModel)
        .environmentObject(paywallConfiguration.screensViewModel)
        .environmentObject(paywallConfiguration.assetsViewModel)
        .onAppear {
            paywallConfiguration.reportOnAppear()
        }
    }
}

#endif
