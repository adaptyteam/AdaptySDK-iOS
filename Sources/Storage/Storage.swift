//
//  Storage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 15.10.2024
//

import Foundation

private let log = Log.storage

final class Storage {
    private enum Constants {
        static let appKeyHash = "AdaptySDK_Application_Key_Hash"
        static let appInstallationIdentifier = "AdaptySDK_Application_Install_Identifier"
        static let appInstallationTime = "AdaptySDK_Application_Install_Time"
    }

    static var userDefaults: UserDefaults { .standard }

    @AdaptyActor
    fileprivate static let appInstallation: (identifier: String, time: Date?) =
        if let identifier = userDefaults.string(forKey: Constants.appInstallationIdentifier) {
            (identifier, userDefaults.object(forKey: Constants.appInstallationTime) as? Date)
        } else {
            createAppInstallationIdentifier()
        }

    @AdaptyActor
    private static func createAppInstallationIdentifier() -> (identifier: String, time: Date) {
        let identifier = UUID().uuidString.lowercased()
        let time = Date()
        log.debug("appInstallationIdentifier = \(identifier), time = \(time)")
        userDefaults.set(identifier, forKey: Constants.appInstallationIdentifier)
        userDefaults.set(time, forKey: Constants.appInstallationTime)
        return (identifier, time)
    }

    @discardableResult
    @AdaptyActor
    static func clearAllDataIfDifferent(apiKey: String) async -> Bool {
        let hash = apiKey.sha256()

        guard let value = userDefaults.string(forKey: Constants.appKeyHash) else {
            userDefaults.set(hash, forKey: Constants.appKeyHash)
            return false
        }

        if value == hash { return false }

        ProfileStorage.clearProfile(newProfileId: nil)
        await EventsStorage.clearAll()
        await ProductVendorIdsStorage.clear()
        await VariationIdStorage.clear()
        userDefaults.set(hash, forKey: Constants.appKeyHash)
        log.verbose("changing apiKeyHash = \(hash).")
        return true
    }
}

extension Environment.Application {
    @AdaptyActor
    static let installationIdentifier = Storage.appInstallation.identifier

    @AdaptyActor
    static let installationTime: Date? = Storage.appInstallation.time
}
