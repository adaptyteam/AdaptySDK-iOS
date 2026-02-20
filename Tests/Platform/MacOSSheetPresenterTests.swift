#if canImport(Testing) && os(macOS) && !targetEnvironment(macCatalyst)

@testable import AdaptyUIBuilder
import Testing

struct PlatformMacOSSheetPresenterTests {
    @Test
    @MainActor
    func defaultMacOSSheetConfigMatchesProductDecisions() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

        let config = AdaptyMacOSSheetConfig.default

        #expect(config.presentationType == .borderlessCustom)
        #expect(config.dismissPolicy.dismissableByOutsideClick)
        #expect(config.dismissPolicy.dismissableByEsc)
        #expect(config.dismissPolicy.dismissableByCustomKeyboardShortcut == nil)
        #expect(config.windowType.baseSize == nil)
        #expect(config.windowType.resizable)
    }

    @Test
    @MainActor
    func screensViewModelStoresProvidedAndDefaultSheetConfigs() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

        let bottomSheet = VC.BottomSheet.create(
            content: .unknown("sheet", nil)
        )
        let viewConfiguration = AdaptyUIConfiguration.create(
            locale: "en",
            templateId: "basic",
            screen: .create(content: .unknown("root", nil)),
            bottomSheets: [
                "sheet-1": bottomSheet,
                "sheet-2": bottomSheet,
            ]
        )
        let viewModel = AdaptyUIScreensViewModel(
            logId: "test",
            viewConfiguration: viewConfiguration
        )

        viewModel.presentScreen(id: "sheet-1")

        let customConfig = AdaptyMacOSSheetConfig(
            presentationType: .titledSystemWindow(title: "Custom Title"),
            dismissPolicy: .init(
                dismissableByOutsideClick: false,
                dismissableByEsc: false,
                dismissableByCustomKeyboardShortcut: .init(
                    key: "w",
                    modifiers: [.command]
                )
            ),
            windowType: .init(
                baseSize: .init(width: 420, height: 360),
                resizable: false
            )
        )
        viewModel.presentScreen(
            id: "sheet-2",
            macOSSheetConfig: customConfig
        )

        #expect(viewModel.activePresentedBottomSheetId == "sheet-2")
        #expect(viewModel.macOSSheetConfig(for: "sheet-1") == .default)
        #expect(viewModel.macOSSheetConfig(for: "sheet-2") == customConfig)
    }

    @Test
    @MainActor
    func activeSheetIdTracksTopPresentedSheet() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

        let bottomSheet = VC.BottomSheet.create(
            content: .unknown("sheet", nil)
        )
        let viewConfiguration = AdaptyUIConfiguration.create(
            locale: "en",
            templateId: "basic",
            screen: .create(content: .unknown("root", nil)),
            bottomSheets: [
                "sheet-1": bottomSheet,
                "sheet-2": bottomSheet,
            ]
        )
        let viewModel = AdaptyUIScreensViewModel(
            logId: "test",
            viewConfiguration: viewConfiguration
        )

        viewModel.presentScreen(id: "sheet-1")
        #expect(viewModel.activePresentedBottomSheetId == "sheet-1")

        viewModel.presentScreen(id: "sheet-2")
        #expect(viewModel.activePresentedBottomSheetId == "sheet-2")

        viewModel.dismissScreen(id: "sheet-2")
        #expect(viewModel.activePresentedBottomSheetId == "sheet-1")

        viewModel.dismissScreen(id: "sheet-1")
        #expect(viewModel.activePresentedBottomSheetId == nil)
    }

    @Test
    @MainActor
    func titledSheetDisablesOutsideClickWhenPolicyIsIncompatible() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

        let config = AdaptyMacOSSheetConfig(
            presentationType: .titledSystemWindow(title: "System"),
            dismissPolicy: .init(
                dismissableByOutsideClick: true,
                dismissableByEsc: true,
                dismissableByCustomKeyboardShortcut: nil
            ),
            windowType: .init(baseSize: nil, resizable: true)
        )

        let resolved = MacOSSheetPresenter.resolvedDismissPolicy(for: config)
        #expect(resolved.dismissableByOutsideClick == false)
        #expect(resolved.dismissableByEsc)
    }

    @Test
    @MainActor
    func escapeKeyConsumptionFollowsDismissPolicy() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

        let dismissableByEsc = AdaptyMacOSSheetDismissPolicy(
            dismissableByOutsideClick: true,
            dismissableByEsc: true,
            dismissableByCustomKeyboardShortcut: nil
        )
        let notDismissableByEsc = AdaptyMacOSSheetDismissPolicy(
            dismissableByOutsideClick: true,
            dismissableByEsc: false,
            dismissableByCustomKeyboardShortcut: nil
        )

        #expect(MacOSSheetPresenter.shouldConsumeEscapeKey(dismissPolicy: dismissableByEsc))
        #expect(MacOSSheetPresenter.shouldConsumeEscapeKey(dismissPolicy: notDismissableByEsc) == false)
    }
}

#endif
