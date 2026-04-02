//
//  PlacementContent.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2025.
//

protocol PlacementContent: Sendable, Codable {
    var placement: AdaptyPlacement { get }
    var id: String { get }
    var variationId: String { get }
    var name: String { get }
}

extension PlacementContent {
    func equalAllLocales(_ other: PlacementContent) -> Bool {
        if let onbording = self as? AdaptyOnboarding, let other = other as? AdaptyOnboarding {
            onbording.remoteConfig?.adaptyLocale == other.remoteConfig?.adaptyLocale
        } else if let flow = self as? AdaptyFlow, let other = other as? AdaptyFlow {
            Set(flow.remoteConfigs.map(\.adaptyLocale)) == Set(other.remoteConfigs.map(\.adaptyLocale))
        } else {
            false
        }
    }

    @inlinable
    func has(languageCode otherLocale: AdaptyLocale?, orDefault: Bool = false) -> Bool {
        if let onbording = self as? AdaptyOnboarding {
            onbording.onbordingHas(languageCode: otherLocale, orDefault: orDefault)
        } else if self is AdaptyFlow {
            true
        } else {
            false
        }
    }

    @inlinable
    func has(variationId: String?) -> Bool {
        guard let variationId else { return true }
        return self.variationId == variationId
    }
}

extension AdaptyOnboarding {
    func onbordingHas(languageCode otherLocale: AdaptyLocale?, orDefault: Bool = false) -> Bool {

        let otherLocale = otherLocale ?? .defaultPlacementLocale
        let orDefault = otherLocale.equalLanguageCode(.defaultPlacementLocale) ? false : orDefault

        return switch remoteConfig?.adaptyLocale {
        case .none:
            if orDefault {
                true
            } else {
                otherLocale.equalLanguageCode(.defaultPlacementLocale)
            }

        case let .some(locale):
            if locale.equalLanguageCode(otherLocale) {
                true
            } else if orDefault {
                locale.equalLanguageCode(.defaultPlacementLocale)
            } else {
                false
            }
        }
    }
}

extension VH where Value: PlacementContent {
    @inlinable
    func has(languageCode locale: AdaptyLocale?, orDefault: Bool = false) -> Bool {
        value.has(languageCode: locale, orDefault: orDefault)
    }

    @inlinable
    func has(variationId: String?) -> Bool {
        value.has(variationId: variationId)
    }
}


extension Sequence {
    func asContentByPlacementId<T: PlacementContent>() -> [String: VH<T>] where Element == VH<T> {
        Dictionary(map { ($0.value.placement.id, $0) }, uniquingKeysWith: { first, second in
            first.value.placement.isNewerThan(second.value.placement) ? first : second
        })
    }
}
