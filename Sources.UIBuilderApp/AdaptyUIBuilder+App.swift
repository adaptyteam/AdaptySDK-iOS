//
//  AdaptyUIBuilder+App.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/23/25.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public extension AdaptyUIBuilder {
//    let schema = AdaptyUISchema(from: "<data>")

    static func getPaywallConfiguration(
        forSchema schema: AdaptyUISchema,
        localeId: LocaleId?,
        products: [ProductResolver],
        tagResolver: AdaptyTagResolver?,
        timerResolver: AdaptyTimerResolver?,
        assetsResolver: AdaptyAssetsResolver?
    ) async throws -> PaywallConfiguration {
        let viewConfiguration = try schema.extractUIConfiguration(withLocaleId: localeId)

        //        AdaptyUIBuilder.sendImageUrlsToObserver(schema, forLocalId: localeId)

        return PaywallConfiguration()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyUIBuilder {
    @MainActor
    final class PaywallConfiguration {}
}
