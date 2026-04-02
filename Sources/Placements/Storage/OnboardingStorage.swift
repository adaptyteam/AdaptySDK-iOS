//
//  OnboardingStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 21.04.2025.
//

import Foundation

private let log = Log.storage

@AdaptyActor
final class OnboardingStorage {
    typealias Content = AdaptyOnboarding

    private enum Constants {
        static let storageKey = "AdaptySDK_Cached_Onboarding"
        static let storageVersionKey = "AdaptySDK_Cached_Onboarding_Version"
        static let currentStorageVersion = 2
    }

    private static let userDefaults = Storage.userDefaults

    static var contentByPlacementId: [String: VH<Content>] = {
        guard userDefaults.integer(forKey: Constants.storageVersionKey) == Constants.currentStorageVersion else {
            return [:]
        }
        do {
            var userInfo = CodingUserInfo()
            return try userDefaults.getJSON(
                [VH<Content>].self,
                forKey: Constants.storageKey
            )?.asContentByPlacementId() ?? [:]
        } catch {
            log.error(error.localizedDescription)
            return [:]
        }
    }()

    static func set(content: Content) {
        contentByPlacementId[content.placement.id] = VH(content, time: Date())
        let array = Array(contentByPlacementId.values)
        guard array.isNotEmpty else {
            userDefaults.removeObject(forKey: Constants.storageKey)
            return
        }

        do {
            try userDefaults.setJSON(array, forKey: Constants.storageKey)
            userDefaults.set(Constants.currentStorageVersion, forKey: Constants.storageVersionKey)

            log.debug("Saving onboarding success.")
        } catch {
            log.error("Saving onboarding fail. \(error.localizedDescription)")
        }
    }

    static func clear() {
        contentByPlacementId = [:]
        userDefaults.removeObject(forKey: Constants.storageKey)
        log.debug("Clear onboarding's.")
    }
}
