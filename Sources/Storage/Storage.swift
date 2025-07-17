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
        static let appLaunchCount = "AdaptySDK_Application_Launch_Count"
    }

    static var userDefaults: UserDefaults { .standard }

    @AdaptyActor
    fileprivate static let appInstallation: (identifier: String, time: Date?, appLaunchCount: Int?) =
        if let identifier = userDefaults.string(forKey: Constants.appInstallationIdentifier), !identifier.isEmpty {
            continueSession(installIdentifier: identifier)
        } else {
            createAppInstallation()
        }

    @AdaptyActor
    private static func continueSession(installIdentifier: String) -> (identifier: String, time: Date?, appLaunchCount: Int?) {
        let time = userDefaults.object(forKey: Constants.appInstallationTime) as? Date
        var appLaunchCount = userDefaults.integer(forKey: Constants.appLaunchCount)

        guard let time, appLaunchCount > 0 else {
            return (installIdentifier, nil, nil)
        }
        appLaunchCount += 1
        userDefaults.set(appLaunchCount, forKey: Constants.appLaunchCount)
        return (installIdentifier, time, appLaunchCount)
    }

    @AdaptyActor
    private static func createAppInstallation() -> (identifier: String, time: Date?, appLaunchCount: Int?) {
        let identifier = UUID().uuidString.lowercased()
        let time = Date()
        let appLaunchCount = 1
        log.debug("appInstallation identifier = \(identifier), time = \(time), appLaunchCount: \(appLaunchCount)")
        userDefaults.set(identifier, forKey: Constants.appInstallationIdentifier)
        userDefaults.set(time, forKey: Constants.appInstallationTime)
        userDefaults.set(appLaunchCount, forKey: Constants.appLaunchCount)

        return (identifier, time, appLaunchCount)
    }

    @discardableResult
    @AdaptyActor
    static func clearAllDataIfDifferent(apiKey: String) async -> Bool {
        let hash = apiKey.sha256.hexString

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

    @AdaptyActor
    static let appLaunchCount: Int? = Storage.appInstallation.appLaunchCount
}
