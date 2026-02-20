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

    @Test
    @MainActor
    func windowSizeFallbackIsUsedWhenWindowMetricsHasZeroOrNegativeSize() {
        guard #available(macOS 12.0, *) else {
            return
        }

        let geometryInsets = EdgeInsets(top: 6, leading: 5, bottom: 4, trailing: 3)
        let geometrySize = CGSize(width: 320, height: 480)

        let zeroSizeMetrics = AdaptyUIWindowMetrics(
            safeAreaInsets: EdgeInsets(top: 40, leading: 14, bottom: 10, trailing: 8),
            windowSize: .zero
        )
        let resolvedSafeAreaWithZeroMetrics = SystemConstantsManager.resolveSafeAreaInsets(
            geometryInsets: geometryInsets,
            windowMetrics: zeroSizeMetrics
        )
        let resolvedSizeWithZeroMetrics = SystemConstantsManager.resolveScreenSize(
            geometrySize: geometrySize,
            resolvedSafeArea: resolvedSafeAreaWithZeroMetrics,
            windowMetrics: zeroSizeMetrics
        )

        #expect(resolvedSafeAreaWithZeroMetrics.top == 40)
        #expect(resolvedSafeAreaWithZeroMetrics.leading == 14)
        #expect(resolvedSafeAreaWithZeroMetrics.bottom == 10)
        #expect(resolvedSafeAreaWithZeroMetrics.trailing == 8)
        #expect(resolvedSizeWithZeroMetrics.width == 342)
        #expect(resolvedSizeWithZeroMetrics.height == 530)

        let negativeSizeMetrics = AdaptyUIWindowMetrics(
            safeAreaInsets: EdgeInsets(top: 30, leading: 12, bottom: 9, trailing: 7),
            windowSize: CGSize(width: -100, height: -50)
        )
        let resolvedSafeAreaWithNegativeMetrics = SystemConstantsManager.resolveSafeAreaInsets(
            geometryInsets: geometryInsets,
            windowMetrics: negativeSizeMetrics
        )
        let resolvedSizeWithNegativeMetrics = SystemConstantsManager.resolveScreenSize(
            geometrySize: geometrySize,
            resolvedSafeArea: resolvedSafeAreaWithNegativeMetrics,
            windowMetrics: negativeSizeMetrics
        )

        #expect(resolvedSafeAreaWithNegativeMetrics.top == 30)
        #expect(resolvedSafeAreaWithNegativeMetrics.leading == 12)
        #expect(resolvedSafeAreaWithNegativeMetrics.bottom == 9)
        #expect(resolvedSafeAreaWithNegativeMetrics.trailing == 7)
        #expect(resolvedSizeWithNegativeMetrics.width == 339)
        #expect(resolvedSizeWithNegativeMetrics.height == 519)
    }

    @Test
    @MainActor
    func metricsTransitionProducesUpdatedResolvedValues() {
        guard #available(macOS 12.0, *) else {
            return
        }

        let geometryInsets = EdgeInsets(top: 3, leading: 2, bottom: 1, trailing: 4)
        let geometrySize = CGSize(width: 420, height: 640)

        let regularWindowMetrics = AdaptyUIWindowMetrics(
            safeAreaInsets: EdgeInsets(top: 28, leading: 12, bottom: 8, trailing: 10),
            windowSize: CGSize(width: 900, height: 700)
        )
        let fullScreenWindowMetrics = AdaptyUIWindowMetrics(
            safeAreaInsets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            windowSize: CGSize(width: 1512, height: 982)
        )

        let regularInsets = SystemConstantsManager.resolveSafeAreaInsets(
            geometryInsets: geometryInsets,
            windowMetrics: regularWindowMetrics
        )
        let fullScreenInsets = SystemConstantsManager.resolveSafeAreaInsets(
            geometryInsets: geometryInsets,
            windowMetrics: fullScreenWindowMetrics
        )

        #expect(regularInsets.top == 28)
        #expect(regularInsets.leading == 12)
        #expect(regularInsets.bottom == 8)
        #expect(regularInsets.trailing == 10)
        #expect(fullScreenInsets.top == 0)
        #expect(fullScreenInsets.leading == 0)
        #expect(fullScreenInsets.bottom == 0)
        #expect(fullScreenInsets.trailing == 0)
        #expect(regularInsets != fullScreenInsets)

        let regularSize = SystemConstantsManager.resolveScreenSize(
            geometrySize: geometrySize,
            resolvedSafeArea: regularInsets,
            windowMetrics: regularWindowMetrics
        )
        let fullScreenSize = SystemConstantsManager.resolveScreenSize(
            geometrySize: geometrySize,
            resolvedSafeArea: fullScreenInsets,
            windowMetrics: fullScreenWindowMetrics
        )

        #expect(regularSize.width == 900)
        #expect(regularSize.height == 700)
        #expect(fullScreenSize.width == 1512)
        #expect(fullScreenSize.height == 982)
        #expect(regularSize != fullScreenSize)
    }

    @Test
    @MainActor
    func interactiveContentSafeAreaPolicyIsContentSafeOnNativeMacOS() {
        guard #available(macOS 12.0, *) else {
            return
        }

        #expect(SystemConstantsManager.ignoresSafeAreaForInteractiveContent == false)
    }
}

#endif
