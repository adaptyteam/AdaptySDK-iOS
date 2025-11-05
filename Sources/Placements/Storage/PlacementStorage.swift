//
//  PlacementStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.10.2022.
//

import Foundation

private let log = Log.storage

@AdaptyActor
final class PlacementStorage {
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

    func restorePaywall(
        _ placementId: String,
        withVariationId: String,
        withInstanceIdentity: String,
        withPlacementVersion: Int64,
        withPlacementRevision: Int
    ) -> AdaptyPaywall? {
        guard let paywall: AdaptyPaywall = Self.getPlacement(placementId)?.value,
              paywall.variationId == withVariationId,
              paywall.instanceIdentity == withInstanceIdentity,
              paywall.placement.version == withPlacementVersion,
              paywall.placement.revision == withPlacementRevision
        else {
            return nil
        }

        return paywall
    }

    func getPlacementById<Content: PlacementContent>(
        _ placementId: String,
        withLocale locale: AdaptyLocale,
        orDefaultLocale: Bool,
        withVariationId variationId: String?
    ) -> VH<Content>? {
        guard
            var content: VH<Content> = Self.getPlacement(placementId),
            content.has(variationId: variationId),
            content.has(languageCode: locale, orDefault: orDefaultLocale)
        else { return nil }

        content.requestLocale = locale
        return content
    }

    private func getNewerPlacement<Content: PlacementContent>(than content: Content) -> Content? {
        guard var cached: Content = Self.getPlacement(content.placement.id)?.value,
              cached.remoteConfig?.adaptyLocale == content.remoteConfig?.adaptyLocale,
              cached.viewConfigurationLocale == content.viewConfigurationLocale,
              cached.variationId == content.variationId,
              cached.placement.isNewerThan(content.placement)
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
