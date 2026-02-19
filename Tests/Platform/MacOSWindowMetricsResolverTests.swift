#if canImport(Testing) && os(macOS) && !targetEnvironment(macCatalyst)

@testable import AdaptyUIBuilder
import SwiftUI
import Testing

struct PlatformMacOSWindowMetricsResolverTests {
    @Test
    @MainActor
    func windowMetricsHavePriorityOnNativeMacOS() {
        guard #available(macOS 12.0, *) else {
            return
        }

        let geometryInsets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let geometrySize = CGSize(width: 100, height: 200)
        let metrics = AdaptyUIWindowMetrics(
            safeAreaInsets: EdgeInsets(top: 40, leading: 14, bottom: 10, trailing: 8),
            windowSize: CGSize(width: 740, height: 560)
        )

        let resolvedInsets = SystemConstantsManager.resolveSafeAreaInsets(
            geometryInsets: geometryInsets,
            windowMetrics: metrics
        )
        #expect(resolvedInsets.top == 40)
        #expect(resolvedInsets.leading == 14)
        #expect(resolvedInsets.bottom == 10)
        #expect(resolvedInsets.trailing == 8)

        let resolvedSize = SystemConstantsManager.resolveScreenSize(
            geometrySize: geometrySize,
            resolvedSafeArea: resolvedInsets,
            windowMetrics: metrics
        )
        #expect(resolvedSize.width == 740)
        #expect(resolvedSize.height == 560)
    }

    @Test
    @MainActor
    func geometryFallbackIsUsedWhenWindowMetricsMissing() {
        guard #available(macOS 12.0, *) else {
            return
        }

        let geometryInsets = EdgeInsets(top: 6, leading: 5, bottom: 4, trailing: 3)
        let geometrySize = CGSize(width: 320, height: 480)

        let resolvedInsets = SystemConstantsManager.resolveSafeAreaInsets(
            geometryInsets: geometryInsets,
            windowMetrics: nil
        )
        #expect(resolvedInsets.top == 6)
        #expect(resolvedInsets.leading == 5)
        #expect(resolvedInsets.bottom == 4)
        #expect(resolvedInsets.trailing == 3)

        let resolvedSize = SystemConstantsManager.resolveScreenSize(
            geometrySize: geometrySize,
            resolvedSafeArea: resolvedInsets,
            windowMetrics: nil
        )
        #expect(resolvedSize.width == 328)
        #expect(resolvedSize.height == 490)
    }
}

#endif
