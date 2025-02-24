//
//  PaywallsStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.10.2022.
//

import Foundation

private let log = Log.storage

private extension AdaptyPaywall {
    var localeOrDefault: AdaptyLocale {
        var remoteConfigLocale = remoteConfig?.adaptyLocale
        if let locale = remoteConfigLocale, locale.equalLanguageCode(.defaultPaywallLocale) {
            remoteConfigLocale = nil
        }
        var viewConfigurationLocale = viewConfiguration?.responseLocale
        if let locale = viewConfigurationLocale, locale.equalLanguageCode(.defaultPaywallLocale) {
            viewConfigurationLocale = nil
        }

        return switch (remoteConfigLocale, viewConfigurationLocale) {
        case (.none, .none): .defaultPaywallLocale
        case let (.some(locale), _),
             let (_, .some(locale)): locale
        }
    }

    func equalLanguageCode(_ paywall: AdaptyPaywall) -> Bool {
        localeOrDefault.equalLanguageCode(paywall.localeOrDefault)
    }
}

@AdaptyActor
final class PaywallsStorage: Sendable {
    private enum Constants {
        static let paywallsStorageKey = "AdaptySDK_Cached_Purchase_Containers"
        static let paywallsStorageVersionKey = "AdaptySDK_Cached_Purchase_Containers_Version"
        static let currentPaywallsStorageVersion = 2
    }

    private static let userDefaults = Storage.userDefaults

    private static var paywallByPlacementId: [String: VH<AdaptyPaywall>] = {
        guard userDefaults.integer(forKey: Constants.paywallsStorageVersionKey) == Constants.currentPaywallsStorageVersion else {
            return [:]
        }
        do {
            return try userDefaults.getJSON([VH<AdaptyPaywall>].self, forKey: Constants.paywallsStorageKey)?.asPaywallByPlacementId ?? [:]
        } catch {
            log.error(error.localizedDescription)
            return [:]
        }
    }()

    func getPaywallByLocale(_ locale: AdaptyLocale, orDefaultLocale: Bool, withPlacementId placementId: String, withVariationId: String?) -> VH<AdaptyPaywall>? {
        guard let paywall = Self.paywallByPlacementId[placementId] else { return nil }
        if let variationId = withVariationId, paywall.value.variationId != variationId {
            return nil
        }
        let paywallLocale = paywall.value.localeOrDefault
        return if paywallLocale.equalLanguageCode(locale) {
            paywall
        } else if orDefaultLocale, paywallLocale.equalLanguageCode(.defaultPaywallLocale) {
            paywall
        } else {
            nil
        }
    }

    private func getNewerPaywall(than paywall: AdaptyPaywall) -> AdaptyPaywall? {
        guard let cached: AdaptyPaywall = Self.paywallByPlacementId[paywall.placementId]?.value,
              cached.equalLanguageCode(paywall),
              cached.variationId == paywall.variationId
        else { return nil }
        return paywall.version >= cached.version ? nil : cached
    }

    func savedPaywallChosen(_ chosen: AdaptyPaywallChosen) -> AdaptyPaywallChosen {
        let paywall = chosen.paywall
        if let newer = getNewerPaywall(than: paywall) { return AdaptyPaywallChosen.restore(newer) }

        Self.paywallByPlacementId[paywall.placementId] = VH(paywall, time: Date())

        let paywalls = Array(Self.paywallByPlacementId.values)

        guard !paywalls.isEmpty else {
            Self.clear()
            return chosen
        }

        do {
            Self.userDefaults.set(Constants.currentPaywallsStorageVersion, forKey: Constants.paywallsStorageVersionKey)
            try Self.userDefaults.setJSON(paywalls, forKey: Constants.paywallsStorageKey)
            log.debug("Saving paywalls success.")
        } catch {
            log.error("Saving paywalls fail. \(error.localizedDescription)")
        }

        return chosen
    }

    static func clear() {
        paywallByPlacementId = [:]
        userDefaults.removeObject(forKey: Constants.paywallsStorageKey)
        log.debug("Clear paywalls.")
    }
}
