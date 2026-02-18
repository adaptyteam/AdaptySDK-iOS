#if canImport(Testing) && os(macOS) && !targetEnvironment(macCatalyst)

@testable import AdaptyUI
import Adapty
import SwiftUI
import Testing

struct PlatformMacOSPaywallAPISurfaceTests {
    @Test
    @MainActor
    func swiftUIPaywallAPIIsVisibleOnNativeMacOS() {
        guard #available(macOS 12.0, *) else {
            return
        }

        let activateReference: (AdaptyUI.Configuration) async throws -> Void = AdaptyUI.activate(configuration:)
        _ = activateReference

        let paywallConfigurationReference: (AdaptyPaywall) async throws -> AdaptyUI.PaywallConfiguration = { paywall in
            try await AdaptyUI.getPaywallConfiguration(forPaywall: paywall)
        }
        _ = paywallConfigurationReference

        let placeholder = AdaptyLoadingPlaceholderView()
        _ = placeholder

        let paywallViewType: AdaptyPaywallView<AdaptyIdentifiablePlaceholder>.Type = AdaptyPaywallView<AdaptyIdentifiablePlaceholder>.self
        _ = paywallViewType

        struct HostView: View {
            @State private var isPresented = false

            var body: some View {
                Text("Host")
                    .paywall(
                        isPresented: $isPresented,
                        paywallConfiguration: nil,
                        didFailPurchase: { _, _ in },
                        didFinishRestore: { _ in },
                        didFailRestore: { _ in },
                        didFailRendering: { _ in }
                    )
            }
        }

        let hostViewType: HostView.Type = HostView.self
        _ = hostViewType
    }
}

#endif
