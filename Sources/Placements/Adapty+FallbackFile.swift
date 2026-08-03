//
//  Adapty+FallbackFile.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension Adapty {
    static var fallbackPlacements: FallbackPlacements?

    /// To set fallback paywalls, use this method. You should pass exactly the same payload you're getting from Adapty backend. You can copy it from Adapty Dashboard.
    ///
    /// Adapty allows you to provide fallback paywalls that will be used when a user opens the app for the first time and there's no internet connection. Or in the rare case when Adapty backend is down and there's no cache on the device.
    ///
    /// Read more on the [Adapty Documentation](https://adapty.io/docs/ios-use-fallback-paywalls)
    ///
    /// - Parameters:
    ///   - fileURL:
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func setFallback(fileURL url: URL) async throws(AdaptyError) {
        try await withoutSDK(
            methodName: .setFallback
        ) { () async throws(AdaptyError) in
            Adapty.fallbackPlacements = try FallbackPlacements(fileURL: url)
        }
    }
}

extension FallbackPlacements {
    @inlinable
    func read<Content: PlacementContent>(
        placementId: String,
        locale: AdaptyLocale?,
        for userId: AdaptyUserId
    ) async -> AdaptyPlacement.Draw<Content>? {
        let crossPlacementState = await CrossPlacementStorage.state(for: userId)
        return try? getPlacement(
            Content.self,
            byPlacementId: placementId,
            withVariationId: crossPlacementState?.variationId(placementId: placementId),
            userId: userId,
            requestLocale: locale
        )
    }
}
