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
        if Content.self == AdaptyFlow.self {
            FlowStorage.contentByPlacementId[placementId] as? VH<Content>
        } else if Content.self == AdaptyOnboarding.self {
            OnboardingStorage.contentByPlacementId[placementId] as? VH<Content>
        } else {
            nil
        }
    }

    private static func setPlacement(_ content: some PlacementContent) {
        if let flow = content as? AdaptyFlow {
            FlowStorage.set(content: flow)
        } else if let onboarding = content as? AdaptyOnboarding {
            OnboardingStorage.set(content: onboarding)
        } else {
            return
        }
    }

//    func restoreFlow(
//        _ placementId: String,
//        withVariationId: String,
//        withInstanceIdentity: String,
//        withPlacementVersion: Int64,
//        withPlacementRevision: Int
//    ) -> AdaptyFlow? {
//        guard let paywall: AdaptyFlow = Self.getPlacement(placementId)?.value,
//              paywall.variationId == withVariationId,
//              paywall.instanceIdentity == withInstanceIdentity,
//              paywall.placement.version == withPlacementVersion,
//              paywall.placement.revision == withPlacementRevision
//        else {
//            return nil
//        }
//
//        return paywall
//    }

    func getPlacementById<Content: PlacementContent>(
        _ placementId: String,
        withLocale locale: AdaptyLocale? = nil,
        orDefaultLocale: Bool,
        withVariationId variationId: String?
    ) -> VH<Content>? {
        guard
            let content: VH<Content> = Self.getPlacement(placementId),
            content.has(variationId: variationId),
            content.has(languageCode: locale, orDefault: orDefaultLocale)
        else { return nil }
        return content
    }

    private func getNewerPlacement<Content: PlacementContent>(than content: Content) -> Content? {
        guard let cached: Content = Self.getPlacement(content.placement.id)?.value,
              cached.equalAllLocales(content),
              cached.variationId == content.variationId,
              cached.placement.isNewerThan(content.placement)
        else { return nil }
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
        FlowStorage.clear()
        OnboardingStorage.clear()
    }
}
