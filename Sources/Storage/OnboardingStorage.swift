//
//  OnboardingStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 21.04.2025.
//

import Foundation

private let log = Log.storage

@AdaptyActor
final class OnboardingStorage: Sendable {
    private enum Constants {
        static let onboardingStorageKey = "AdaptySDK_Cached_Onboarding"
        static let onboardingStorageVersionKey = "AdaptySDK_Cached_Onboarding_Version"
        static let currentOnboardingStorageVersion = 1
    }

    private static let userDefaults = Storage.userDefaults

    static var onboardingByPlacementId: [String: VH<AdaptyOnboarding>] = {
        guard userDefaults.integer(forKey: Constants.onboardingStorageVersionKey) == Constants.currentOnboardingStorageVersion else {
            return [:]
        }
        do {
            return try userDefaults.getJSON([VH<AdaptyOnboarding>].self, forKey: Constants.onboardingStorageKey)?.asOnboardingByPlacementId ?? [:]
        } catch {
            log.error(error.localizedDescription)
            return [:]
        }
    }()

    static func setOnboarding(_ onboarding: AdaptyOnboarding) {
        onboardingByPlacementId[onboarding.placement.id] = VH(onboarding, time: Date())
        let array = Array(onboardingByPlacementId.values)
        guard !array.isEmpty else {
            userDefaults.removeObject(forKey: Constants.onboardingStorageKey)
            return
        }

        do {
            try userDefaults.setJSON(array, forKey: Constants.onboardingStorageKey)
            userDefaults.set(Constants.currentOnboardingStorageVersion, forKey: Constants.onboardingStorageVersionKey)

            log.debug("Saving onboarding success.")
        } catch {
            log.error("Saving onboarding fail. \(error.localizedDescription)")
        }
    }

    static func clear() {
        onboardingByPlacementId = [:]
        userDefaults.removeObject(forKey: Constants.onboardingStorageKey)
        log.debug("Clear onboarding's.")
    }
}
