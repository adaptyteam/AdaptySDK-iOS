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
        static let persistedInstallationIdentifierToAppSupportStorage = "AdaptySDK_AppSupport_Install_Identifier"
    }

    static var userDefaults: UserDefaults { .standard }

    @AdaptyActor
    fileprivate static var appInstallation: (identifier: String, time: Date?, appLaunchCount: Int?) =
        if let identifier = userDefaults.string(forKey: Constants.appInstallationIdentifier).nonEmptyOrNil {
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

    @AdaptyActor
    private static func checkIsInstallIdentifierDifferent() -> Bool {
        let identifier = appInstallation.identifier
        guard userDefaults.bool(forKey: Constants.persistedInstallationIdentifierToAppSupportStorage) else {
            if AppSupportStorage.setInstallIdentifier(identifier) {
                userDefaults.setValue(true, forKey: Constants.persistedInstallationIdentifierToAppSupportStorage)
            }
            return false
        }

        return identifier != AppSupportStorage.getTnstallIdentifier()
    }

    @AdaptyActor
    private static func checkIsApiKeyDifferent(hash: String) -> Bool {
        guard let value = userDefaults.string(forKey: Constants.appKeyHash) else {
            userDefaults.set(hash, forKey: Constants.appKeyHash)
            return false
        }
        return value != hash
    }

    @discardableResult
    @AdaptyActor
    static func clearAllDataIf(differentApiKey apiKey: String, onRestoreFromBackup: Bool) async -> Bool {
        let clearInstallId = checkIsInstallIdentifierDifferent() && onRestoreFromBackup

        if clearInstallId {
            appInstallation = createAppInstallation()
            if AppSupportStorage.setInstallIdentifier(appInstallation.identifier) {
                userDefaults.setValue(true, forKey: Constants.persistedInstallationIdentifierToAppSupportStorage)
            }
        }

        let hash = apiKey.sha256.hexString
        let clearData = checkIsApiKeyDifferent(hash: hash) || clearInstallId

        guard clearData else { return false }
        ProfileStorage.clearProfile()
        await EventsStorage.clearAll()
        await BackendProductInfoStorage.clear()
        await PurchasePayloadStorage.clear()
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
