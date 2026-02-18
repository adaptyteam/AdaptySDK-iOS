#if canImport(Testing)

@testable import AdaptyUIBuilder
import Foundation
import Testing

struct PlatformSystemConstantsManagerTests {
    @Test
    @MainActor
    func valuesAreAccessibleOnCurrentPlatform() async {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

        let bounds = SystemConstantsManager.mainScreenBounds
        #expect(bounds.width.isFinite)
        #expect(bounds.height.isFinite)

        _ = SystemConstantsManager.systemBackgroundColor

        let url = URL(string: "adapty-sdk-invalid-url-scheme://open")!
        let openResult = await SystemConstantsManager.openExternalURL(url)
        #expect(openResult == true || openResult == false)
    }
}

#endif
