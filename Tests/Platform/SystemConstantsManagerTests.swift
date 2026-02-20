#if canImport(Testing)

@testable import AdaptyUIBuilder
import Foundation
import SwiftUI
import Testing

struct PlatformSystemConstantsManagerTests {
    private func expectInsets(
        _ insets: EdgeInsets,
        top: CGFloat,
        leading: CGFloat,
        bottom: CGFloat,
        trailing: CGFloat
    ) {
        #expect(insets.top == top)
        #expect(insets.leading == leading)
        #expect(insets.bottom == bottom)
        #expect(insets.trailing == trailing)
    }

    @Test
    @MainActor
    func valuesAreAccessibleOnCurrentPlatform() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

        let bounds = SystemConstantsManager.mainScreenBounds
        #expect(bounds.width.isFinite)
        #expect(bounds.height.isFinite)

        _ = SystemConstantsManager.systemBackgroundColor

        let httpsURL = URL(string: "https://adapty.io")!
        let customSchemeURL = URL(string: "adapty-sdk-invalid-url-scheme://open")!

        #expect(
            SystemConstantsManager.resolvedPresentationForCurrentPlatform(
                .browserOutApp,
                url: httpsURL
            ) == .browserOutApp
        )

        let resolvedInAppHTTPS = SystemConstantsManager.resolvedPresentationForCurrentPlatform(
            .browserInApp,
            url: httpsURL
        )

#if os(iOS)
        #expect(resolvedInAppHTTPS == .browserInApp)
#else
        #expect(resolvedInAppHTTPS == .browserOutApp)
#endif

        #expect(
            SystemConstantsManager.resolvedPresentationForCurrentPlatform(
                .browserInApp,
                url: customSchemeURL
            ) == .browserOutApp
        )
    }

    @Test
    @MainActor
    func invalidCustomSchemeReturnsFalseOnNativeMacOS() async {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

#if os(macOS) && !targetEnvironment(macCatalyst)
        let invalidCustomSchemeURL = URL(string: "adapty-sdk-invalid-url-scheme://open")!
        let result = await SystemConstantsManager.openExternalURL(
            invalidCustomSchemeURL,
            presentation: .browserOutApp
        )

        #expect(result == false)
#endif
    }

    @Test
    @MainActor
    func invalidCustomSchemeWithInAppPresentationReturnsFalseOnNativeMacOS() async {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

#if os(macOS) && !targetEnvironment(macCatalyst)
        let invalidCustomSchemeURL = URL(string: "adapty-sdk-invalid-url-scheme://open")!
        let result = await SystemConstantsManager.openExternalURL(
            invalidCustomSchemeURL,
            presentation: .browserInApp
        )

        #expect(result == false)
#endif
    }

    @Test
    @MainActor
    func safeAreaAndScreenSizeResolversUsePlatformPolicy() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

        let geometryInsets = EdgeInsets(top: 11, leading: 7, bottom: 5, trailing: 3)
        let geometrySize = CGSize(width: 300, height: 500)

        let resolvedSafeAreaWithoutMetrics = SystemConstantsManager.resolveSafeAreaInsets(
            geometryInsets: geometryInsets,
            windowMetrics: nil
        )
        expectInsets(
            resolvedSafeAreaWithoutMetrics,
            top: 11,
            leading: 7,
            bottom: 5,
            trailing: 3
        )

        let resolvedScreenWithoutMetrics = SystemConstantsManager.resolveScreenSize(
            geometrySize: geometrySize,
            resolvedSafeArea: resolvedSafeAreaWithoutMetrics,
            windowMetrics: nil
        )
        #expect(resolvedScreenWithoutMetrics.width == 310)
        #expect(resolvedScreenWithoutMetrics.height == 516)

        let windowMetrics = AdaptyUIWindowMetrics(
            safeAreaInsets: EdgeInsets(top: 44, leading: 12, bottom: 8, trailing: 6),
            windowSize: CGSize(width: 940, height: 760)
        )

        let resolvedSafeAreaWithMetrics = SystemConstantsManager.resolveSafeAreaInsets(
            geometryInsets: geometryInsets,
            windowMetrics: windowMetrics
        )

#if os(macOS) && !targetEnvironment(macCatalyst)
        expectInsets(
            resolvedSafeAreaWithMetrics,
            top: 44,
            leading: 12,
            bottom: 8,
            trailing: 6
        )
#else
        expectInsets(
            resolvedSafeAreaWithMetrics,
            top: 11,
            leading: 7,
            bottom: 5,
            trailing: 3
        )
#endif

        let resolvedScreenWithMetrics = SystemConstantsManager.resolveScreenSize(
            geometrySize: geometrySize,
            resolvedSafeArea: resolvedSafeAreaWithMetrics,
            windowMetrics: windowMetrics
        )

#if os(macOS) && !targetEnvironment(macCatalyst)
        #expect(resolvedScreenWithMetrics.width == 940)
        #expect(resolvedScreenWithMetrics.height == 760)
#else
        #expect(resolvedScreenWithMetrics.width == 310)
        #expect(resolvedScreenWithMetrics.height == 516)
#endif
    }
}

#endif
