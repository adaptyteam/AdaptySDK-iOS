#if canImport(Testing)

@testable import AdaptyUIBuilder
import Foundation
import Testing

struct PlatformSystemConstantsManagerTests {
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

}

#endif
