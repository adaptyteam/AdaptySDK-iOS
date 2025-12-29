//
//  AppSupportStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.12.2025.
//

import Foundation

private let log = Log.storage

enum AppSupportStorage {
    private enum Constants {
        static let fileName = "adapty.sdk"
    }

    private struct SDKInfo: Codable {
        let installIdentifier: String

        enum CodingKeys: String, CodingKey {
            case installIdentifier = "install_identifier"
        }
    }

    @AdaptyActor
    static func getTnstallIdentifier() -> String? {
        do {
            guard let data = try AppDirectory.applicationSupport(fileName: Constants.fileName) else { return nil }
            return try JSONDecoder().decode(SDKInfo.self, from: data).installIdentifier
        } catch {
            log.error("Load \(Constants.fileName) error: \(error)")
            return nil
        }
    }

    @AdaptyActor
    static func setInstallIdentifier(_ value: String) -> Bool {
        log.debug("AppSupportStorage setInstallIdentifier = \(value)")

        do {
            let data = try JSONEncoder().encode(SDKInfo(installIdentifier: value))
            try AppDirectory.setApplicationSupport(data: data, fileName: Constants.fileName)
            return true
        } catch {
            log.error("AppSupportStorage Save \(Constants.fileName) error: \(error)")
            return false
        }
    }
}
