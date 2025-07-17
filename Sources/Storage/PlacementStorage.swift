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
    private static func getPlacement<Content: PlacementContent>(_ placementId: String) -> VH<Content>? {
        if Content.self == AdaptyPaywall.self {
            return PaywallStorage.paywallByPlacementId[placementId] as? VH<Content>
        } else if Content.self == AdaptyOnboarding.self {
            return OnboardingStorage.onboardingByPlacementId[placementId] as? VH<Content>
        } else {
            return nil
        }
    }

    private static func setPlacement(_ content: some PlacementContent) {
        if let paywall = content as? AdaptyPaywall {
            PaywallStorage.setPaywall(paywall)
        } else if let onboarding = content as? AdaptyOnboarding {
            OnboardingStorage.setOnboarding(onboarding)
        } else {
            return
        }
    }

    func getPlacementByLocale<Content: PlacementContent>(
        _ locale: AdaptyLocale,
        orDefaultLocale: Bool,
        withPlacementId placementId: String,
        withVariationId: String?
    ) -> VH<Content>? {
        guard var content: VH<Content> = Self.getPlacement(placementId) else { return nil }

        if let variationId = withVariationId, content.value.variationId != variationId {
            return nil
        }

        let contentLocale = content.value.localeOrDefault

        if contentLocale.equalLanguageCode(locale) {
            content.requestLocale = locale
            return content
        } else if orDefaultLocale, contentLocale.equalLanguageCode(.defaultPlacementLocale) {
            content.requestLocale = locale
            return content
        } else {
            return nil
        }
    }

    private func getNewerPlacement<Content: PlacementContent>(than content: Content) -> Content? {
        guard var cached: Content = Self.getPlacement(content.placement.id)?.value,
              cached.equalLanguageCode(content),
              cached.variationId == content.variationId,
              content.placement.version < cached.placement.version
        else { return nil }
        cached.requestLocale = content.requestLocale
        return cached
    }

    func savedPlacementChosen<Content: PlacementContent>(_ chosen: AdaptyPlacementChosen<Content>) -> AdaptyPlacementChosen<Content> {
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
