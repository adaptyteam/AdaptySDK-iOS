//
//  PlacementStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.10.2022.
//

import Foundation

private let log = Log.storage

@AdaptyActor
final class PlacementStorage: Sendable {
    private static func getPlacement<Content: AdaptyPlacementContent>(_ placementId: String) -> VH<Content>? {
        if Content.self == AdaptyPaywall.self {
            return PaywallStorage.paywallByPlacementId[placementId] as? VH<Content>
        } else if Content.self == AdaptyOnboarding.self {
            return OnboardingStorage.onboardingByPlacementId[placementId] as? VH<Content>
        } else {
            return nil
        }
    }

    private static func setPlacement<Content: AdaptyPlacementContent>(_ content: Content) {
        if let paywall = content as? AdaptyPaywall {
            PaywallStorage.setPaywall(paywall)
        } else if let onboarding = content as? AdaptyOnboarding {
            OnboardingStorage.setOnboarding(onboarding)
        } else {
            return
        }
    }

    func getPlacementByLocale<Content: AdaptyPlacementContent>(
        _ locale: AdaptyLocale,
        orDefaultLocale: Bool,
        withPlacementId placementId: String,
        withVariationId: String?
    ) -> VH<Content>? {
        guard let content: VH<Content> = Self.getPlacement(placementId) else { return nil }

        if let variationId = withVariationId, content.value.variationId != variationId {
            return nil
        }
        let contentLocale = content.value.localeOrDefault
        return if contentLocale.equalLanguageCode(locale) {
            content
        } else if orDefaultLocale, contentLocale.equalLanguageCode(.defaultPlacementLocale) {
            content
        } else {
            nil
        }
    }

    private func getNewerPlacement<Content: AdaptyPlacementContent>(than content: Content) -> Content? {
        guard let cached: Content = Self.getPlacement(content.placement.id)?.value,
              cached.equalLanguageCode(content),
              cached.variationId == content.variationId
        else { return nil }
        return content.placement.version >= cached.placement.version ? nil : cached
    }

    func savedPlacementChosen<Content: AdaptyPlacementContent>(_ chosen: AdaptyPlacementChosen<Content>) -> AdaptyPlacementChosen<Content> {
        let content = chosen.content

        Log.crossAB.verbose("savedPlacementChosen variationId: \(content.variationId), placementId: \(content.placement.id), version: \(content.placement.version)")

        if let newer = getNewerPlacement(than: content) { return AdaptyPlacementChosen.restore(newer) }

        Self.setPlacement(content)
        return chosen
    }

    static func clear() {
        PaywallStorage.clear()
        OnboardingStorage.clear()
    }
}

private extension AdaptyPlacementContent {
    private func viewConfigurationLocale() -> AdaptyLocale? {
        if let paywall = self as? AdaptyPaywall {
            paywall.viewConfiguration?.responseLocale
        } else if let onboarding = self as? AdaptyOnboarding {
            onboarding.viewConfiguration.responseLocale
        } else {
            nil
        }
    }

    var localeOrDefault: AdaptyLocale {
        var remoteConfigLocale = remoteConfig?.adaptyLocale
        if let locale = remoteConfigLocale, locale.equalLanguageCode(.defaultPlacementLocale) {
            remoteConfigLocale = nil
        }
        var viewConfigurationLocale = viewConfigurationLocale()
        if let locale = viewConfigurationLocale, locale.equalLanguageCode(.defaultPlacementLocale) {
            viewConfigurationLocale = nil
        }

        return switch (remoteConfigLocale, viewConfigurationLocale) {
        case (.none, .none): .defaultPlacementLocale
        case let (.some(locale), _),
             let (_, .some(locale)): locale
        }
    }

    func equalLanguageCode(_ content: Self) -> Bool {
        localeOrDefault.equalLanguageCode(content.localeOrDefault)
    }
}
