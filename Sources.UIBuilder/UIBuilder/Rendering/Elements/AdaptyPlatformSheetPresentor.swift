//
//  AdaptyPlatformSheetPresentor.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 18.02.2026.
//

import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyPlatformSheetPresentor: View {
    @Environment(\.adaptySafeAreaInsets) private var safeAreaInsets
    @Environment(\.adaptyScreenSize) private var screenSize
    @Environment(\.layoutDirection) private var layoutDirection

    @EnvironmentObject private var paywallViewModel: AdaptyUIPaywallViewModel
    @EnvironmentObject private var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject private var actionsViewModel: AdaptyUIActionsViewModel
    @EnvironmentObject private var sectionsViewModel: AdaptyUISectionsViewModel
    @EnvironmentObject private var screensViewModel: AdaptyUIScreensViewModel
    @EnvironmentObject private var tagResolverViewModel: AdaptyUITagResolverViewModel
    @EnvironmentObject private var timerViewModel: AdaptyUITimerViewModel
    @EnvironmentObject private var assetsViewModel: AdaptyUIAssetsViewModel

    var body: some View {
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        AdaptyNativeMacOSSheetHost(
            contentBuilder: makeNativeSheetContent
        )
        .environmentObject(screensViewModel)
#else
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(!screensViewModel.presentedScreensStack.isEmpty ? 0.4 : 0.0)
                .onTapGesture {
                    screensViewModel.dismissTopScreen()
                }

            ForEach(screensViewModel.bottomSheetsViewModels, id: \.id) { vm in
                AdaptyUIBottomSheetView()
                    .environmentObject(vm)
            }
        }
#endif
    }

    private func makeNativeSheetContent(
        for viewModel: AdaptyUIBottomSheetViewModel
    ) -> AnyView {
        AnyView(
            AdaptyUIElementView(viewModel.bottomSheet.content)
                .withScreenId(viewModel.id)
                .withSafeArea(safeAreaInsets)
                .withScreenSize(screenSize)
                .environment(\.layoutDirection, layoutDirection)
                .environmentObject(paywallViewModel)
                .environmentObject(productsViewModel)
                .environmentObject(actionsViewModel)
                .environmentObject(sectionsViewModel)
                .environmentObject(screensViewModel)
                .environmentObject(tagResolverViewModel)
                .environmentObject(timerViewModel)
                .environmentObject(assetsViewModel)
        )
    }
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
private struct AdaptyNativeMacOSSheetHost: View {
    @EnvironmentObject private var screensViewModel: AdaptyUIScreensViewModel

    @State private var presenter = MacOSSheetPresenter()
    @State private var parentWindow: NSWindow?

    let contentBuilder: (AdaptyUIBottomSheetViewModel) -> AnyView

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .background(
                MacOSSheetParentWindowReader(window: $parentWindow)
                    .frame(width: 0, height: 0)
            )
            .onAppear {
                syncPresentation()
            }
            .onChange(of: parentWindow) { _ in
                syncPresentation()
            }
            .onChange(of: screensViewModel.presentedScreensStack) { _ in
                syncPresentation()
            }
            .onDisappear {
                presenter.cleanup()
            }
    }

    private func syncPresentation() {
        guard
            let activeSheetId = screensViewModel.activePresentedBottomSheetId,
            let activeBottomSheetViewModel = screensViewModel.bottomSheetsViewModels.first(
                where: { $0.id == activeSheetId }
            )
        else {
            presenter.sync(
                parentWindow: parentWindow,
                sheetId: nil,
                config: AdaptyMacOSSheetConfig.default,
                content: nil
            ) { screenId in
                screensViewModel.dismissScreen(id: screenId)
            }
            return
        }

        presenter.sync(
            parentWindow: parentWindow,
            sheetId: activeSheetId,
            config: screensViewModel.macOSSheetConfig(for: activeSheetId),
            content: contentBuilder(activeBottomSheetViewModel)
        ) { screenId in
            screensViewModel.dismissScreen(id: screenId)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
private struct MacOSSheetParentWindowReader: NSViewRepresentable {
    @Binding private var window: NSWindow?

    init(window: Binding<NSWindow?>) {
        _window = window
    }

    func makeNSView(context: Context) -> WindowTrackingView {
        let view = WindowTrackingView()
        view.onWindowChanged = { [weak coordinator = context.coordinator] window in
            coordinator?.update(window: window)
        }
        context.coordinator.update(window: view.window)
        return view
    }

    func updateNSView(_ nsView: WindowTrackingView, context: Context) {
        context.coordinator.update(window: nsView.window)
    }

    static func dismantleNSView(_ nsView: WindowTrackingView, coordinator: Coordinator) {
        nsView.onWindowChanged = nil
        coordinator.update(window: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(window: $window)
    }

    @MainActor
    final class Coordinator {
        private let windowBinding: Binding<NSWindow?>

        init(window: Binding<NSWindow?>) {
            windowBinding = window
        }

        func update(window: NSWindow?) {
            windowBinding.wrappedValue = window
        }
    }
}

#endif
