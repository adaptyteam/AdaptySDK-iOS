//
//  AdaptyUIBuilder+FlowView.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 9/23/25.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUIFlowViewModifier<Placeholder>: ViewModifier where Placeholder: View {
    @Environment(\.presentationMode) private var presentationMode

    private let isPresented: Binding<Bool>
    private let fullScreen: Bool

    private let flowConfiguration: AdaptyUIBuilder.FlowConfiguration?

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
        flowConfiguration: AdaptyUIBuilder.FlowConfiguration?,
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
        self.flowConfiguration = flowConfiguration
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
    private var flowOrProgressView: some View {
        if let flowConfiguration {
            AdaptyUIFlowView(
                flowConfiguration: flowConfiguration,
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

    func body(content: Content) -> some View {
        if fullScreen {
            content
                .fullScreenCover(
                    isPresented: isPresented,
                    onDismiss: {
                        flowConfiguration?.reportOnDisappear()
                    },
                    content: {
                        flowOrProgressView
                    }
                )
        } else {
            content
                .sheet(
                    isPresented: isPresented,
                    onDismiss: {
                        flowConfiguration?.reportOnDisappear()
                    },
                    content: {
                        flowOrProgressView
                    }
                )
        }
    }
}

@MainActor
public extension View {
    func flow<Placeholder: View>(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        flowConfiguration: AdaptyUIBuilder.FlowConfiguration?,
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
            AdaptyUIFlowViewModifier<Placeholder>(
                isPresented: isPresented,
                fullScreen: fullScreen,
                flowConfiguration: flowConfiguration,
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

@MainActor
public struct AdaptyUIFlowView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private let flowConfiguration: AdaptyUIBuilder.FlowConfiguration

    private let didAppear: (() -> Void)?
    private let didDisappear: (() -> Void)?
    private let didPerformAction: ((AdaptyUIBuilder.Action) -> Void)?
    private let didSelectProduct: ((ProductResolver) -> Void)?
    private let didStartPurchase: ((ProductResolver) -> Void)?
    private let didStartRestore: (() -> Void)?
    private let didFailRendering: ((AdaptyUIBuilderError) -> Void)?

    public init(
        flowConfiguration: AdaptyUIBuilder.FlowConfiguration,
        didAppear: (() -> Void)? = nil,
        didDisappear: (() -> Void)? = nil,
        didPerformAction: ((AdaptyUIBuilder.Action) -> Void)? = nil,
        didSelectProduct: ((ProductResolver) -> Void)? = nil,
        didStartPurchase: ((ProductResolver) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFailRendering: @escaping (AdaptyUIBuilderError) -> Void
    ) {
        self.flowConfiguration = flowConfiguration
        self.didAppear = didAppear
        self.didDisappear = didDisappear
        self.didPerformAction = didPerformAction
        self.didSelectProduct = didSelectProduct
        self.didStartPurchase = didStartPurchase
        self.didStartRestore = didStartRestore
        self.didFailRendering = didFailRendering
    }

    public var body: some View {
        flowConfiguration.eventsHandler.didAppear = didAppear
        flowConfiguration.eventsHandler.didDisappear = didDisappear

        flowConfiguration.eventsHandler.didPerformAction = didPerformAction ?? { action in
            switch action {
            case .close:
                presentationMode.wrappedValue.dismiss()
            case let .openURL(url):
                UIApplication.shared.open(url, options: [:])
            case .custom:
                break
            }
        }

        flowConfiguration.eventsHandler.didSelectProduct = didSelectProduct ?? { _ in }
        flowConfiguration.eventsHandler.didStartPurchase = didStartPurchase ?? { _ in }

        flowConfiguration.eventsHandler.didStartRestore = didStartRestore ?? {}
        flowConfiguration.eventsHandler.didFailRendering = didFailRendering

        return AdaptyUIPaywallView_Internal(
            showDebugOverlay: false,
            displayMissingTags: false
        )
        .environmentObjects(
            stateViewModel: flowConfiguration.stateViewModel,
            flowViewModel: flowConfiguration.flowViewModel,
            productsViewModel: flowConfiguration.productsViewModel,
            tagResolverViewModel: flowConfiguration.tagResolverViewModel,
            timerViewModel: flowConfiguration.timerViewModel,
            screensViewModel: flowConfiguration.screensViewModel,
            assetsViewModel: flowConfiguration.assetsViewModel
        )
        .onAppear {
            flowConfiguration.reportOnAppear()
        }
    }
}

#endif
