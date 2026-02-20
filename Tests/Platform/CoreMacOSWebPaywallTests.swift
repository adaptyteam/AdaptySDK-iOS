#if canImport(Testing) && os(macOS) && !targetEnvironment(macCatalyst)

@testable import Adapty
import enum Adapty.AdaptyWebPresentation
import Foundation
import Testing

struct PlatformCoreMacOSWebPaywallTests {
    private func invalidCustomSchemeURL() -> URL {
        let scheme = "adapty-sdk-invalid-url-scheme-\(UUID().uuidString.lowercased())"
        return URL(string: "\(scheme)://open")!
    }

    @Test
    @MainActor
    func invalidCustomSchemeReturnsFalseOnNativeMacOS() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

        let invalidCustomSchemeURL = invalidCustomSchemeURL()
        var openWasCalled = false

        let result = invalidCustomSchemeURL.openmacOS(
            presentation: AdaptyWebPresentation.externalBrowser,
            canOpenExternalURL: { _ in false },
            openExternalURL: { _ in
                openWasCalled = true
                return true
            }
        )

        #expect(result == false)
        #expect(openWasCalled == false)
    }

    @Test
    @MainActor
    func invalidCustomSchemeWithInAppPresentationReturnsFalseOnNativeMacOS() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

        let invalidCustomSchemeURL = invalidCustomSchemeURL()
        var openWasCalled = false

        let result = invalidCustomSchemeURL.openmacOS(
            presentation: AdaptyWebPresentation.inAppBrowser,
            canOpenExternalURL: { _ in false },
            openExternalURL: { _ in
                openWasCalled = true
                return true
            }
        )

        #expect(result == false)
        #expect(openWasCalled == false)
    }
}

#endif
